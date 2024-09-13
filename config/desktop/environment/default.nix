{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.desktop.environment;
in {
  imports = configLib.scanPath ./.;

  options.cfg.desktop.environment = {
    kde.enable = mkEnableOption "KDE";
    hyprland.enable = mkEnableOption "Hyprland";
  };

  config = mkIf (cfg.kde.enable || cfg.hyprland.enable) {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    environment.systemPackages = [pkgs.xdg-user-dirs];
    environment.etc."xdg/user-dirs.defaults".text = ''
      DESKTOP=xdg/desktop
      DOWNLOAD=downloads
      TEMPLATES=xdg/templates
      PUBLICSHARE=xdg/public
      DOCUMENTS=xdg/documents
      MUSIC=xdg/music
      PICTURES=xdg/photos
      VIDEOS=xdg/video
    '';
  };
}
