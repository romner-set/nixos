{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.cfg.desktop.environment.hyprland.enable {
    programs.hyprland.enable = true;
    environment.sessionVariables.NIXOS_OZONE_WL = 1;
  };
}
