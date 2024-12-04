{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.cfg.microvm.services.watchtower;
in {
  options.cfg.microvm.services.watchtower = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    cfg.microvm.services.docker.watchtower = {
      enable = true;
      compose = ./docker-compose.yml;
    };
  };
}
