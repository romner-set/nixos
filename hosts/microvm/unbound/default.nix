{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;
in {
  config = {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = ["0.0.0.0" "::0"];
          qname-minimisation = "yes";
          access-control = [
            "0.0.0.0/0 allow"
            "::0/0 allow"
            /*
                     "127.0.0.0/8 allow"
                   "::1/128 allow"
            "10.47.0.0/16 allow" #TODO
                   "${ipv4.subnet.microvm}.0/24 allow"
                   "${ipv4.subnet.microvmHost}.0/24 allow"
                   "${ipv4.publicSubnetAddr}/${toString ipv4.publicSubnetSize} allow"
                   "${ipv6.prefix}${ipv6.subnet.lan}::/64 allow"
                   "${ipv6.subnet.microvm}::/64 allow"
                   "${ipv6.subnet.microvmHost}::/64 allow"
            */
          ];
          ede = "yes";
          harden-glue = "yes";
          harden-large-queries = "yes";
          harden-below-nxdomain = "yes";
          harden-referral-path = "yes";
          harden-algo-downgrade = "yes";
          harden-short-bufsize = "yes";
          harden-dnssec-stripped = "yes";
          val-clean-additional = "yes";
          aggressive-nsec = "yes";
          use-caps-for-id = "no";
          hide-identity = "yes";
          hide-version = "yes";
          msg-cache-size = "128m";
          msg-cache-slabs = "2";
          rrset-roundrobin = "yes";
          rrset-cache-size = "256m";
          rrset-cache-slabs = "2";
          key-cache-size = "256m";
          key-cache-slabs = "2";
          cache-min-ttl = "0";
          serve-expired = "yes";
          prefetch = "yes";
          prefetch-key = "yes";
          so-reuseport = "yes";
          num-threads = 4;
          so-rcvbuf = "2m";
        };
        local-zone = [
          "vm.${domain}. static"
          "_acme-challenge.${domain}. transparent"
          "ns1.${domain}. transparent"
          "ns2.${domain}. transparent"
          "${domain}. redirect"
        ];
        local-data = concatLists [
          (concatLists (attrsets.mapAttrsToList (vmName: vmData: [
              "\"${vmName}.vm.${domain}. A ${ipv4.subnet.microvm}.${toString vmData.id}\""
              "\"${vmName}.vm.${domain}. AAAA ${ipv6.subnet.microvm}::${toString vmData.id}\""
            ])
            vmsEnabled))
          [
            # main redirect
            "\"${domain}. A ${ipv4.address}\""
            "\"${domain}. AAAA ${ipv6.address}\""
          ]
        ];
      };
    };
  };
}
