{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.svc.watchtower;
in {
  options.svc.watchtower = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    svc.docker.watchtower = {
      enable = true;
      compose = ./docker-compose.yml;
    };
  };
}
