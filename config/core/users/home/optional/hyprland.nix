# TODO: hyprland
{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.cfg.desktop.environment.hyprland.enable {
    home-manager.users =
      lib.attrsets.mapAttrs (name: _: {
        wayland.windowManager.hyprland = {
          enable = true;
          settings = {
          };
        };
      })
      config.cfg.core.users;
  };
}
