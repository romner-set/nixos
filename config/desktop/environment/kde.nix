{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.cfg.desktop.environment.kde.enable {
    services.xserver.xkb.variant = "colemak";
    services.xserver.enable = true;
    # per-host: services.xserver.videoDrivers = ["nvidia"];
    #services.xserver.displayManager.sddm.enable = true;
    #services.xserver.desktopManager.plasma5.enable = true;
    services.displayManager.sddm.enable = true;
    #services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    /*
      qt = { #TODO: styling?
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
    */
  };
}
