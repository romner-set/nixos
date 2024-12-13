{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.svc.cron;
in {
  options.svc.cron = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    services.cron = {
      enable = true;
      #mailto = "alerts@${config.networking.domain}";
      mailto = "root";
    };
  };
}
