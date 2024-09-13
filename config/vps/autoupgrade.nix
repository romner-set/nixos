{
  config,
  lib,
  inputs,
  ...
}:
with lib; {
  options.cfg.vps.autoUpgrade.enable = mkEnableOption "";

  config = mkIf config.cfg.vps.autoUpgrade.enable {
    system.autoUpgrade = {
      enable = true;
      dates = "04:30";
      flake = toString inputs.self;
      allowReboot = true;
      randomizedDelaySec = "60min";
    };
  };
}
