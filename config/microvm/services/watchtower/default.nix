{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.cfg.microvm.services.watchtower;
  compose = ./docker-compose.yml;
in {
  options.cfg.microvm.services.watchtower = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = mkDefault true;
    environment.systemPackages = with pkgs; [docker-compose];
    systemd.services.watchtower = {
      script = ''
        docker-compose -f ${compose} up
      '';
      wantedBy = ["multi-user.target"];
      after = ["docker.service" "docker.socket"];
      path = [pkgs.docker-compose];
    };
  };
}
