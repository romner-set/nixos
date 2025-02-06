{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.cfg.desktop.environment.hyprland;
in {
  /*
    options.cfg.desktop.environment.hyprland.services.hyprlock = {
  };
  */

  config = lib.mkIf cfg.enable {
    home-manager.users =
      lib.attrsets.mapAttrs (name: _: {
        programs.hyprlock = {
          enable = true;
          settings = {
            general = {
              disable_loading_bar = true;
              hide_cursor = true;
              ignore_empty_input = true;
              grace = 5;
            };

            background = {
              path = "${./hyprpaper/wallpapers/rocket.png}";
              blur_passes = 2;
            };

            input-field = {
              size = "250, 60";
              outline_thickness = 2;
              dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
              dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
              dots_center = true;
              outer_color = "rgba(0, 0, 0, 0)";
              inner_color = "rgba(100, 114, 125, 0.4)";
              font_color = "rgb(200, 200, 200)";
              fade_on_empty = false;
              font_family = "SF Pro Display Bold";
              placeholder_text = "<span foreground=\"##ffffff99\">locked</span>";
              hide_input = false;
              position = "0, -225";
              halign = "center";
              valign = "center";
            };

            label = [
              {
                text = "cmd[update:1000] echo \"<span>$(date +\"%H:%M\")</span>\"";
                color = "rgba(216, 222, 233, 0.70)";
                font_size = 130;
                font_family = "SF Pro Display Bold";
                position = "0, 240";
                halign = "center";
                valign = "center";
              }
              {
                text = "cmd[update:1000] echo -e \"$(date +\"%A, %d %B\")\"";
                color = "rgba(216, 222, 233, 0.70)";
                font_size = 30;
                font_family = "SF Pro Display Bold";
                position = "0, 105";
                halign = "center";
                valign = "center";
              }
              /*
                {
                text = "$USER";
                color = "rgba(216, 222, 233, 0.70)";
                font_size = 25;
                font_family = "SF Pro Display Bold";
                position = "0, -130";
                halign = "center";
                valign = "center";
              }
              */
            ];
          };
        };
      })
      config.cfg.core.users;
  };
}
