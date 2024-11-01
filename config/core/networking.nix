{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.core.net;
in {
  options.cfg.core.net = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    systemdDefault = mkEnableOption "";

    dns = {
      enable = mkEnableOption "";
      nameservers = mkOption {
        type = with types; listOf str;
        default = ["9.9.9.9"];
      };
    };
  };

  config = mkIf cfg.enable {
    services.resolved.enable = !cfg.dns.enable;
    environment.etc."resolv.conf".text = mkIf cfg.dns.enable (
      (strings.concatStrings (map (ns: "nameserver ${ns}\n") cfg.dns.nameservers))
      + "options edns0 trust-ad\n"
    );

    networking.hosts = {
      "127.0.0.2" = lib.mkForce [];
      "127.0.0.1" = lib.mkForce ["localhost"];
      "::1" = lib.mkForce ["localhost"];
    };

    networking.useDHCP = mkDefault (!cfg.systemdDefault);
    systemd.network = mkIf cfg.systemdDefault {
      enable = true;
      networks."10-wan" = {
        matchConfig.Name = ["enp*" "eno*" "eth*"];
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
