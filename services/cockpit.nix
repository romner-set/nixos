{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.svc.cockpit;
in {
  options.svc.cockpit = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    services.cockpit = {
      enable = true;
      port = 9090;
      settings = {WebService = {AllowUnencrypted = true;};};
    };
  };
}
