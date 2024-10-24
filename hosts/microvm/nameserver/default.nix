{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) vms net;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;

  cfg = {
    inherit lib domain vms net;
    host = {
      ipv4 = ipv4.publicAddress;
      ipv6 = ipv6.publicAddress;
    };
    addrs = [
      {
        ipv4 = "162.55.33.86";
        ipv6 = "2a01:4f8:c010:91ac::1";
        cert-key = "Dz14HoMs3cuczSYTUscntbB7ZRb7JAGg98/pP+Rv0tk="; # pubkeys, safe to expose
      }
      {
        ipv4 = "144.24.191.4";
        ipv6 = "2603:c020:8016:9fff::fff";
        cert-key = "CYBwKpSfuc8T91RR7vQxmngdE58zxXZk4p+R+WWYLew=";
      }
    ];
  };
  domainZone = pkgs.writeText "domain.zone" (import ./domain.zone.nix cfg);
in {
  config = {
    # KnotDNS
    systemd.services.knot.serviceConfig.Group = lib.mkForce "root"; # access /secrets/rendered/acme.conf
    services.knot = {
      enable = true;
      keyFiles = ["/secrets/rendered/acme.conf"];
      settings = {
        server = rec {
          listen = ["0.0.0.0@53" "::@53"];
          listen-quic = ["0.0.0.0@853" "::@853"];
          identity = "${config.cfg.microvm.host.hostName}.${domain}";
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
  };
}
