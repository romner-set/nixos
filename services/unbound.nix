{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.svc.unbound;
in {
  options.svc.unbound.enable = mkEnableOption "";

  config = mkIf cfg.enable {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          interface = [
            "::1"
            #"127.0.0.1"
          ];
          access-control = [
            "0.0.0.0/0 refuse"
            "::0/0 refuse"
            #"127.0.0.0/8 allow"
            "::1/128 allow"
          ];
          qname-minimisation = "yes";
          ede = "yes";
          harden-below-nxdomain = "yes";
          harden-referral-path = "yes";
          harden-algo-downgrade = "no";
          use-caps-for-id = "no";
          hide-identity = "yes";
          hide-version = "yes";
          msg-cache-size = "128m";
          msg-cache-slabs = "2";
          rrset-cache-size = "256m";
          rrset-cache-slabs = "2";
          key-cache-size = "256m";
          key-cache-slabs = "2";
          cache-min-ttl = "0";
          serve-expired = "yes";
          prefetch = "yes";
          num-threads = 4;
        };
        /*
        local-zone = [
          "${domain}. redirect"
        ];
        local-data = [
          "\"${domain}. A 127.0.0.1\""
        ];
        */
      };
    };
  };
}
