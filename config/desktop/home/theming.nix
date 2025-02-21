{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.cfg.desktop.home;
in {
  options.cfg.desktop.home.theming.enable = mkOption {
    type = types.bool;
    default = cfg.enable;
  };
  config = mkIf cfg.theming.enable {
    environment.systemPackages = with pkgs; [
      andromeda-gtk-theme
      dracula-icon-theme
    ];

    home-manager.users =
      attrsets.mapAttrs (name: _: {
        home.sessionVariables.GTK_THEME = "Andromeda";
        gtk = {
	  enable = true;
	  theme.name = "Andromeda";
	  iconTheme.name = "Dracula";
	};
      })
      (config.cfg.core.users // {root = {};});
  };
}
