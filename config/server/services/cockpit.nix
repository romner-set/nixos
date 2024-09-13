{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.server.services.cockpit;
in {
  options.cfg.server.services.cockpit = {
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
