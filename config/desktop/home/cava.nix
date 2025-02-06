{
  lib,
  config,
  ...
}: with lib; let
  cfg = config.cfg.desktop.home;
in {
  options.cfg.desktop.home.cava.enable = mkOption {
    type = types.bool;
    default = cfg.enable;
  };
  config = mkIf cfg.cava.enable {
    home-manager.users =
      attrsets.mapAttrs (name: _: {
        programs.cava = {
          enable = true;
          settings = {
            general.bar_width = 1;
            input.method = "pipewire";
            input.source = "auto";
            color.gradient = 1;
            color.gradient_count = 2;
            color.gradient_color_1 = "'#C620FF'";
            color.gradient_color_2 = "'#2864FF'";
          };
        };
      })
      (config.cfg.core.users // {root = {};});
  };
}
