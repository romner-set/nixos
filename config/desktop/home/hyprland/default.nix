{
  lib,
  config,
  configLib,
  pkgs,
  inputs,
  ...
} @ args:
with lib; let
  cfg = config.cfg.desktop.environment.hyprland;
in {
  imports = configLib.scanPaths [./programs];

  options.cfg.desktop.environment.hyprland = {
    binds = let
      mkStrOption = default: mkOption {
        type = types.str;
        inherit default;
      };
    in {
      volumeSteps = {
        large = mkStrOption "25%";
        normal = mkStrOption "5%";
        small = mkStrOption "1%";
        precise = mkStrOption "0.1%";
      };
      brightnessSteps = {
        large = mkStrOption "25%";
        normal = mkStrOption "5%";
        small = mkStrOption "1%";
        precise = mkStrOption "1";
      };
    };

    monitors = mkOption {
      type = with types;
        attrsOf (submodule ({name, ...}: {
          options = {
            name = mkOption {
              type = types.str;
              default = name;
            };

            resolution = mkOption {
              type = types.str;
              default = "preferred";
            };

            position = mkOption {
              type = types.str;
              default = "auto";
            };

            scale = mkOption {
              type = types.numbers.positive;
              default = 1;
            };

            extraArgs = mkOption {
              type = types.str;
              default = "";
            };
          };
        }));
      default = {};
    };

    inputDevices = mkOption {
      type = with types;
        attrsOf (submodule ({name, ...}: {
          freeformType = with types; attrsOf (oneOf [str number bool]);
          options = {
            name = mkOption {
              type = types.str;
              default = name;
            };
          };
        }));
      default = {};
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tofi
      hyprpicker
      wl-clipboard
      clipse
      physlock
      hyprsysteminfo
      inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
      iwgtk
      nautilus
      overskride
    ];

    # default rule for undefined monitors
    cfg.desktop.environment.hyprland.monitors."" = {
      resolution = "preferred";
      position = "auto";
      scale = 1;
    };

    home-manager.users =
      attrsets.mapAttrs (name: _: {
        programs.fish = {
          enable = true;
          loginShellInit = ''
            if test (tty) = "/dev/tty1"
              set -Ux HYPRLAND_SHELL_EXIT 0

              if uwsm check may-start; uwsm start hyprland-uwsm.desktop; end

              # see binds.nix, $mainMod+M logs out while $mainMod+K exits to shell
              exec fish -c 'if test $HYPRLAND_SHELL_EXIT -eq 1; set -Ux HYPRLAND_SHELL_EXIT 0; exec fish; end'
            end
          '';
        };

        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = false; # UWSM support

          extraConfig = (import ./binds.nix args) + cfg.extraConfig;
          settings = {
            env = [
              "HYPRCURSOR_THEME,rose-pine-hyprcursor"
            ];

            exec-once = [
              "systemctl start --user waybar"
              #"wl-clip-persist --clipboard regular"
              #"wl-paste --watch cliphist store"
              "clipse -listen"
            ];

            monitor = attrsets.mapAttrsToList (n: v: "${n}, ${v.resolution}, ${v.position}, ${toString v.scale}${v.extraArgs}") cfg.monitors;

            input = {
              kb_layout = "us,us";
              kb_variant = "colemak,basic";
              kb_options = "grp:shift_caps_toggle";

              numlock_by_default = true;
              touchpad.natural_scroll = false;
            };

            device = attrsets.mapAttrsToList (_: settings: settings) cfg.inputDevices;

            gestures = {
              workspace_swipe = true;
              workspace_swipe_distance = 200;
              workspace_swipe_invert = false;
            };

            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
            };

            debug.disable_logs = true;

            general = {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more

              gaps_in = 5;
              gaps_out = 10;
              border_size = 2;
              "col.active_border" = "rgba(33ccffff) rgba(cc33ffff) 45deg #33ccff #cc33ff";
              #col.inactive_border = "rgba(595959aa)";
              "col.inactive_border" = "rgba(cc33ffaa) rgba(33ccffaa) 45deg #cc33ff #33ccff";

              layout = "dwindle";
            };

            decoration = {
              # See https://wiki.hyprland.org/Configuring/Variables/ for more

              #rounding = 5
              blur = {
                size = 20;
                passes = 2;
                new_optimizations = true;
                ignore_opacity = true;
              };

              shadow = {
                enabled = true;
                range = 4;
                render_power = 3;
                color = "rgba(1a1a1aee)";
              };

              #inactive_opacity = 0.85;
              #inactive_opacity = 0.5;
              #active_opacity   = 0.8;
            };

            animations = {
              enabled = true;

              # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

              bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

              animation = [
                "windows, 1, 7, myBezier"
                "windowsOut, 1, 7, default, popin 80%"
                "border, 1, 10, default"
                "fade, 1, 7, default"
                "workspaces, 1, 6, default"
              ];
            };

            dwindle = {
              # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
              pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in binds.nix
              preserve_split = true;
            };

            windowrulev2 = [
              # xwaylandvideobridge
              "opacity 0.0 override, class:^(xwaylandvideobridge)$"
              "noanim, class:^(xwaylandvideobridge)$"
              "noinitialfocus, class:^(xwaylandvideobridge)$"
              "maxsize 1 1, class:^(xwaylandvideobridge)$"
              "noblur, class:^(xwaylandvideobridge)$"
              "nofocus, class:^(xwaylandvideobridge)$"
              # clipse
              "float,class:(clipse)" # ensure you have a floating window class set if you want this behavior
              "size 622 652,class:(clipse)" # set the size of the window as necessary
              # iwgtk
              "float,class:(org.twosheds.iwgtk)"
              "size 622 652,class:(org.twosheds.iwgtk)"
            ];
          };
        };

        home.sessionVariables.NIXOS_OZONE_WL = "1";
      })
      config.cfg.core.users;
  };
}
