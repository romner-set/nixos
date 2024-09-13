{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.cfg.desktop.environment.hyprland.enable {
    programs.hyprland.enable = true;
  };
}
