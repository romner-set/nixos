{
  config,
  lib,
  ...
}:
with lib; {
  options.cfg.desktop.bluetooth.enable = mkEnableOption "Bluetooth";

  config = mkIf config.cfg.desktop.bluetooth.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    #services.blueman.enable = true;
  };
}
