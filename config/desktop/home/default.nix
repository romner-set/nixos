{lib, configLib, ...}: {
  imports = configLib.scanPath ./.;

  options.cfg.desktop.home.enable = lib.mkEnableOption "";
}
