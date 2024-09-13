{
  lib,
  pkgs,
  config,
  hostNetwork,
  vms,
  ...
}:
with lib; let
  inherit (hostNetwork) ipv4 ipv6;
  inherit (config.networking) domain;

  cfg = {
    inherit lib domain vms;
    host = {
      ipv4 = ipv4.publicAddress;
      ipv6 = ipv6.publicAddress;
    };
    addrs = [
      {
        ipv4 = "162.55.33.86";
        ipv6 = "2a01:4f8:c010:91ac::1";
        cert-key = "Mz0Djp8W1LIl5oazGfY2Hr3oPqTj93Z8acvXDs4Ms58="; # pubkeys, safe to expose
      }
      {
        ipv4 = "144.24.191.4";
        ipv6 = "2603:c020:8016:9fff::fff";
        cert-key = "WnHKA98GSQcJm1X6NLSFTEfU9NiHS/kQeZmgPWsFRRc=";
      }
    ];
  };
  domainZone = pkgs.writeText "domain.zone" (import ./domain.zone.nix cfg);
in {
  config = {
    # ACME
    users.users.acme.uid = 60;
    users.groups.acme.gid = 60;
    security.acme = {
      preliminarySelfsigned = false;
      acceptTerms = true;

      certs."${domain}" = {
        extraDomainNames = [
          "*.${domain}"
          "*.vm.${domain}"
        ];
        #dnsResolver = "${(builtins.elemAt cfg.addrs 1).ipv4}:53";
        dnsPropagationCheck = false;

        #reloadServices = ["nginx"];
        server = "https://acme.zerossl.com/v2/DV90";
        email = "admin@${domain}";

        #mox mail doesn't support this as of yet: ocspMustStaple = true;
        keyType = "ec384";
        extraLegoRenewFlags = ["--reuse-key"]; # for static TLSA records

        dnsProvider = "rfc2136";
        environmentFile = "/secrets/acme.env";

        /*
          postRun = ''
          chown -R 60:60 /var/lib/acme/${domain}
        '';
        */
        # nginx
      };
    };

    # KnotDNS
    systemd.services.knot.serviceConfig.User = lib.mkForce "root"; # access to /secrets/acme.conf
    #systemd.services.knot.serviceConfig.Group = lib.mkForce "root";
    #systemd.services.knot.serviceConfig.BindPaths = ["/secrets"];
    services.knot = {
      enable = true;
      keyFiles = ["/secrets/acme.conf"];
      settings = {
        server = rec {
          listen = ["::1@53"];
          listen-quic = ["0.0.0.0@853" "::@853"];
          identity = "${config.networking.hostName}.${domain}";
          nsid = identity;
          version = "KnotDNS";
          #automatic-acl = "on";

          tcp-io-timeout = 100;
          #tcp-reuseport = "on"; # enable on secondary
        };

        mod-rrl = [
          {
            id = "default";
            rate-limit = 1000;
            slip = 2;
          }
        ];

        remote =
          lists.imap1 (
            i: addr: {
              id = "ns${toString i}";
              address = addr.ipv4;
              cert-key = addr.cert-key;
              quic = "on";
            }
          )
          cfg.addrs;

        template = [
          {
            id = "default";
            global-module = "mod-rrl/default";
            journal-content = "all";
            zonefile-sync = -1;
            zonefile-load = "difference-no-serial";
            dnssec-signing = "on";
            dnssec-policy = "ecc";
            #zonemd-generate = "zonemd-sha512";
            serial-policy = "dateserial";
          }
        ];

        zone = [
          {
            domain = domain;
            #storage = "/data/";
            file = domainZone; #"domain.zone";
            #reverse-generate = domain;
            notify = lists.imap1 (i: addr: "ns${toString i}") cfg.addrs;
            acl = ["allow-secondary" "acme"];
          }
        ];

        policy = [
          {
            id = "ecc";
            algorithm = "ed25519";
            reproducible-signing = "on";
            nsec3 = "on";
          }
        ];

        acl = [
          {
            id = "allow-secondary";
            cert-key = map (addr: addr.cert-key) cfg.addrs;
            action = ["transfer" "notify"];
          }
          {
            id = "acme";
            key = "acme";
            action = ["update"];
            update-type = "TXT";
            update-owner = "name";
            update-owner-match = "equal";
            update-owner-name = ["_acme-challenge" "_acme-challenge.vm"];
          }
        ];
      };
    };

    # BIND9
    /*
        services.bind = {
        enable = true;
        listenOn = ["any"];
        listenOnIpv6 = ["any"];
        forwarders = mkForce [];
        cacheNetworks = [
          "127.0.0.0/8"
          "::1/128"
        ];
        extraOptions = ''
                 dnssec-validation auto;
                 version "not currently available";

          rate-limit {
    			window 15; // Seconds to bucket
    			responses-per-second 100;// # of good responses per prefix-length/sec
    			referrals-per-second 20; // referral responses
    			nodata-per-second 20; // nodata responses
    			nxdomains-per-second 20; // nxdomain responses
    			errors-per-second 20; // error responses
    			all-per-second 100; // When we drop all
    			log-only no; // Debugging mode
    			exempt-clients {};
    			ipv4-prefix-length 24; // Define the IPv4 block size
    			ipv6-prefix-length 56; // Define the IPv6 block size
    			max-table-size 20000; // 40 bytes * this number = max memory
    			min-table-size 500; // pre-allocate to speed startup
    };
        '';
        #response-policy { zone "rpz"; };
        zones = {
          /*"rpz" = {
            master = true;
            file = rpzZone;
          };
    */
    /*
        "${domain}" = {
          master = true;
          file = domainZone;
        };
      };
    };
    */
  };
}
