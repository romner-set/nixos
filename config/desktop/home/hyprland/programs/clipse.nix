{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.cfg.desktop.environment.hyprland;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users =
      lib.attrsets.mapAttrs (name: _: {
        home.file.".config/clipse/custom_theme.json" = {
          text = builtins.toJSON {
            useCustomTheme = true;
            TitleFore = "#C0CAF5";
            TitleBack = config.home-manager.users.${name}.programs.kitty.settings.background;
            TitleInfo = "#C0CAF5";
            NormalTitle = "#7AA2F7";
            DimmedTitle = "#3B4261";
            SelectedTitle = "#7DCFFF";
            NormalDesc = "#A9B1D6";
            DimmedDesc = "#3B4261";
            SelectedDesc = "#7AA2F7";
            StatusMsg = "#BB9AF7";
            PinIndicatorColor = "#FF9E64";
            SelectedBorder = "#7AA2F7";
            SelectedDescBorder = "#7DCFFF";
            FilteredMatch = "#9ECE6A";
            FilterPrompt = "#E0AF68";
            FilterInfo = "#C0CAF5";
            FilterText = "#C0CAF5";
            FilterCursor = "#F7768E";
            HelpKey = "#7AA2F7";
            HelpDesc = "#C0CAF5";
            PageActiveDot = "#9ECE6A";
            PageInactiveDot = "#3B4261";
            DividerDot = "#F7768E";
            PreviewedText = "#C0CAF5";
            PreviewBorder = "#BB9AF7";
          };
        };
      })
      config.cfg.core.users;
  };
}
