{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cfg.core.firmware;
in {
  options.cfg.core.firmware = {
    enable = mkEnableOption "firmware";
    allowUnfree = mkOption {
      type = types.bool;
      default = false;
    };
    microcode = mkOption {
      type = types.str;
      default = "amd";
    };
  };
  config = mkIf cfg.enable {
    hardware.enableAllFirmware = cfg.allowUnfree;
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.${cfg.microcode}.updateMicrocode = true;

    services.fwupd.enable = true;
  };
}
