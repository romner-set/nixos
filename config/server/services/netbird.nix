{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.server.services.netbird;
in {
  options.cfg.server.services.netbird = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    services.netbird.enable = true;
  };
}
