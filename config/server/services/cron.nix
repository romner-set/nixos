{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.server.services.cron;
in {
  options.cfg.server.services.cron = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    services.cron = {
      enable = true;
      mailto = "alerts@${config.networking.domain}";
    };
  };
}
