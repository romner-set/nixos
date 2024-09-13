{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.core.boot;
in {
  config = mkIf cfg.loader.grub.enable {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = !cfg.efiVars;
      memtest86.enable = true;
      mirroredBoots = [
        #TODO:
        {
          devices = ["nodev"];
          path = "/boot";
        }
      ];
    };
  };
}
