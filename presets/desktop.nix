{lib, ...}:
with lib; {
  cfg.core = {
    users.main.enable = mkDefault true;
    firmware.enable = mkDefault true;
    # per-host: boot.loader.<name>.enable = mkDefault true;
  };

  cfg.desktop = {
    programs.enable = mkDefault true;
    sound.enable = mkDefault true;
    bluetooth.enable = mkDefault true;
    fonts.enable = mkDefault true;

    # per-host: environment.<name>.enable = true;
    # per-host: graphics.<name>.enable = true;
  };

  svc.endlessh.enable = mkDefault true;
}
