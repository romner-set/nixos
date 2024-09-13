{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cfg.server.power;
in {
  options.cfg.server.power = {
    ignoreKeys = mkEnableOption "";
  };

  config = mkIf cfg.ignoreKeys {
    services.logind = {
      powerKey = "ignore";
      powerKeyLongPress = "ignore";
      rebootKey = "ignore";
      rebootKeyLongPress = "ignore";
    };

    /*
      services.acpid = {
      enable = true;
      handlers.power = {
      };
    };
    */
  };
}
