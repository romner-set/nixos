{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.desktop.environment.hyprland;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users =
      lib.attrsets.mapAttrs (name: _: {
        services.dunst = {
          enable = true;
          configFile = "${./dunstrc}";
        };
      })
      config.cfg.core.users;
  };
}
