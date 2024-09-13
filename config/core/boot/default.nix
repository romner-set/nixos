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
  imports = configLib.scanPath ./.;

  options.cfg.core.boot = {
    loader.grub.enable = mkEnableOption "";
    loader.systemd-boot.enable = mkEnableOption "";

    efiVars = mkEnableOption "";

    fs = mkOption {
      type =
        types.coercedTo
        (types.listOf types.str)
        (enabled: lib.listToAttrs (map (fs: lib.nameValuePair fs true) enabled))
        (types.attrsOf types.bool);
      default = ["ntfs"];
    };
  };

  config = {
    boot.supportedFilesystems = cfg.fs;
    boot.loader.efi.canTouchEfiVariables = cfg.efiVars;
  };
}
