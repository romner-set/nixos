{
  config,
  lib,
  ...
}:
with lib; {
  options.cfg.core.locale.enable = mkOption {
    type = types.bool;
    default = true;
  };
  config = mkIf config.cfg.core.locale.enable {
    time.timeZone = "Europe/Prague";
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = lib.mkForce "colemak";
      useXkbConfig = true;
    };
  };
}
