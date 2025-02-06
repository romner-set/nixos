{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.cfg.desktop.environment.hyprland;
in {
  options.cfg.desktop.environment.hyprland = {
    autoLogin = {
      enable = mkOption {
        type = types.bool;
        default = cfg.autoLogin.user != null;
      };
      user = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;
    environment.sessionVariables.NIXOS_OZONE_WL = 1;

    systemd.services."getty@tty1" = lib.mkIf cfg.autoLogin.enable {
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [
        "" # override upstream default with an empty ExecStart
        "@${pkgs.utillinux}/sbin/agetty agetty --login-program ${pkgs.shadow}/bin/login --autologin ${cfg.autoLogin.user} --noclear %I $TERM"
      ];
    };
  };
}
