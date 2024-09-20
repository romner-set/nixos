{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.desktop.services.sunshine;
in {
  options.cfg.desktop.services.sunshine = {
    enable = mkEnableOption "";
    openFirewall = mkEnableOption "";
    monitor = mkOption {
      type = types.int;
      default = 0;
    };
  };

  config = mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      openFirewall = cfg.openFirewall;
      settings = {
        wan_encryption_mode = 2; #forced
        lan_encryption_mode = 2;
        output_name = cfg.monitor;
        address_family = "both";
      };
      capSysAdmin = true;
    };
  };
}
