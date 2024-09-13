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
      flake = "git+https://git.${config.networking.domain}/romner-set/nixos";
      allowReboot = true;
      randomizedDelaySec = "60min";
    };
  };
}
