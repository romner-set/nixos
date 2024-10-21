{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.cfg.desktop.environment.kde;
in {
  options.cfg.desktop.environment.kde = {
    session = mkOption {
      type = types.str;
      default = "plasma";
    };
    autoLogin = {
      enable = mkOption {
        type = types.bool;
        default = config.cfg.desktop.environment.kde.autoLogin.user != null;
      };
      user = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };
  };

  config = lib.mkIf config.cfg.desktop.environment.kde.enable {
    services.xserver.xkb.variant = "colemak";
    services.xserver.enable = true;

    # per-host: services.xserver.videoDrivers = ["nvidia"];
    services.desktopManager.plasma6.enable = true;

    services.displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = true;

      defaultSession = cfg.session;

      # autoLogin.user = "main";
      sddm.settings.Autologin = lib.mkIf cfg.autoLogin.enable {
        Session = "${cfg.session}.desktop";
        User = cfg.autoLogin.user;
      };
    };

    /*
      qt = { #TODO: styling?
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
    */
  };
}
