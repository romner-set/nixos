{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (config.networking) domain;
  cfg = config.svc.knot;
in {
  options.svc.knot = {
    enable = mkEnableOption "";
    quicKey = mkOption {type = types.str;};
    primaryAddr = mkOption {type = types.str;};
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [53];
    networking.firewall.allowedUDPPorts = [53 853];

    # KnotDNS
    systemd.services.knot.serviceConfig.BindPaths = ["/data/knot"];
    services.knot = {
      enable = true;
      settings = {
        server = rec {
          version = "KnotDNS";
          tcp-io-timeout = 100;
          tcp-reuseport = "on"; # enable only on secondaries
          #automatic-acl = "on";
        };

        database.storage = "/data/knot";

        mod-rrl = [
          {
            id = "default";
            rate-limit = 1000;
            slip = 2;
          }
        ];

        remote = [
          {
            id = "primary";
            address = ["${cfg.primaryAddr}@853"];
            cert-key = cfg.quicKey;
            quic = "on";
          }
        ];

        template = [
          {
            id = "default";
            global-module = "mod-rrl/default";
            journal-content = "all";
            zonefile-sync = -1;
            zonefile-load = "none";
            dnssec-validation = "on";
            #zonemd-generate = "zonemd-sha512";
            serial-policy = "dateserial";
          }
        ];

        zone = [
          {
            inherit domain;
            master = "primary";
            acl = "allow-primary";
          }
        ];

        acl = [
          {
            id = "allow-primary";
            cert-key = cfg.quicKey;
            action = ["transfer" "notify"];
          }
        ];
      };
    };
  };
}
