{lib, ...}:
with lib; {
  cfg.core = {
    users.main.enable = mkDefault true;
    firmware.enable = mkDefault true;
    # per-host: boot.loader.<name>.enable = mkDefault true;
  };

  svc.endlessh.enable = mkDefault true;

  cfg.desktop = {
    programs.enable = mkDefault true;
    sound.enable = mkDefault true;
    bluetooth.enable = mkDefault true;
    fonts.enable = mkDefault true;

    # per-host: environment.<name>.enable = true;
    # per-host: graphics.<name>.enable = true;

    environment.hyprland.inputDevices = {
      "logitech-gaming-mouse-g502" = {
        accel_profile = "flat";
        sensitivity = -0.35;
      };
    };
  };
}
