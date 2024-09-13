{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.cfg.vps.services.rathole;
in {
  options.cfg.vps.services.rathole.enable = mkEnableOption "";

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443 444];
    networking.firewall.allowedUDPPorts = [443];

    environment.systemPackages = with pkgs; [rathole];

    systemd.services.rathole = {
      description = "rathole service";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.rathole}/bin/rathole /data/rathole.toml";
        Restart = "on-failure";
      };
      wantedBy = ["default.target"];
    };
  };
}
