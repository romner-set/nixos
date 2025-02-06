# TODO: hyprland
{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.cfg.desktop.home;
in {
  options.cfg.desktop.home.kitty.enable = mkOption {
    type = types.bool;
    default = cfg.enable;
  };
  config = mkIf cfg.kitty.enable {
    home-manager.users =
      lib.attrsets.mapAttrs (name: _: {
        programs.kitty = {
          enable = true;
          extraConfig = ''
            map kitty_mod+o     next_tab
            map kitty_mod+i     previous_tab
            map kitty_mod+t     new_tab
            #map kitty_mod+q     close_tab
            map kitty_mod+.     move_tab_forward
            map kitty_mod+,     move_tab_backward
            map kitty_mod+alt+t set_tab_title

            map kitty_mod+up        scroll_line_up
            map kitty_mod+k         scroll_line_up
            map kitty_mod+down      scroll_line_down
            map kitty_mod+j         scroll_line_down
            map kitty_mod+u 	      scroll_page_up
            map kitty_mod+d 	      scroll_page_down
            map kitty_mod+home      scroll_home
            map kitty_mod+end       scroll_end
            map kitty_mod+h         show_scrollback
          '';
          settings = {
            font_family = "MesloLGS Nerd Font Mono";
            font_size = 9.0;

            # vim:ft=kitty

            background_opacity = 0.75;
            window_padding_width = 15;
            allow_remote_control = true;
            enable_audio_bell = false;
            url_style = "single";
            tab_bar_style = "powerline";

            # The basic colors
            foreground = "#abb2bf";
            background = "#1e222a";
            selection_foreground = "#3e4452";
            selection_background = "#303742";

            # Kitty window border colors
            active_border_color = "#33CCFF";
            inactive_border_color = "#6C7086";
            bell_border_color = "#F9EF55";

            # OS Window titlebar colors
            wayland_titlebar_color = "system";
            macos_titlebar_color = "system";

            # Tab bar colors
            active_tab_foreground = "#11111B";
            active_tab_background = "#CBA6F7";
            inactive_tab_foreground = "#CDD6F4";
            inactive_tab_background = "#181825";
            tab_bar_background = "#11111B";

            # Colors for marks (marked text in the terminal)
            mark1_foreground = "#1E1E2E";
            mark1_background = "#B4BEFE";
            mark2_foreground = "#1E1E2E";
            mark2_background = "#CBA6F7";
            mark3_foreground = "#1E1E2E";
            mark3_background = "#74C7EC";

            # The 16 terminal colors

            # black
            color0 = "#45475A";
            color8 = "#585B70";

            # red
            color1 = "#b6193C";
            color9 = "#E6193C";

            # green
            color2 = "#19BBEE";
            color10 = "#33ccff";
            #color2  #2929A3
            #color10 #3939b3

            # yellow
            color3 = "#e3e322";
            color11 = "#ffff22";

            # blue
            color4 = "#3D5bF5";
            color12 = "#4579ff";

            # magenta
            color5 = "#d92bff";
            color13 = "#ef22FF";

            # cyan
            color6 = "#19BBEE";
            color14 = "#33ccff";

            # white
            color7 = "#A6ADC8";
            color15 = "#BAC2DE";
          };
        };
      })
      config.cfg.core.users;
  };
}
