{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.cfg.desktop.environment.hyprland;
in {
  options.cfg.desktop.environment.hyprland.services.waybar = {
    diskPath = mkOption {
      type = types.str;
      default = "/home";
    };
    tempSensor = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users =
      lib.attrsets.mapAttrs (name: _: {
        programs.waybar = {
          enable = true;
          settings = {
            mainBar = {
              layer = "top";
              position = "top";
              height = 0;
              margin-left = 10;
              margin-right = 10;
              margin-top = 10;

              modules-left = [
                "group/power"
                "clock"
                "group/hardware"
                "mpris"
              ];
              modules-center = ["hyprland/window"];
              modules-right = [
                #"cava"
                "tray"
                "network"
                "bluetooth"
                "privacy"
                "hyprland/language"
                "group/backlight"
                "group/audio"
                "battery"
                "hyprland/workspaces"
              ];

              "group/hardware" = {
                orientation = "inherit";
                modules = [
                  "cpu"
                  (
                    if cfg.services.waybar.tempSensor != null
                    then "temperature"
                    else null
                  )
                  "memory"
                  "disk"
                ];
                drawer = {};
              };
              cpu = {
                format = " {avg_frequency}GHz {icon} {usage}%";
                format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
                interval = 1;
              };
              temperature = {
                hwmon-path = cfg.services.waybar.tempSensor or "";
                format = "{temperatureC}°C ";
              };
              memory = {
                interval = 1;
                format = "{used:0.1f}G/{total:0.1f}G ";
              };
              disk = {
                format = "{used} 󰋊 {percentage_used}%";
                path = cfg.services.waybar.diskPath;
              };

              "group/backlight" = {
                orientation = "inherit";
                modules = ["backlight" "backlight/slider"];
                drawer = {};
              };
              "backlight/slider" = {
                min = 0;
                max = 100;
                orientation = "horizontal";
              };
              backlight = {
                device = "intel_backlight";
                format = "{icon} {percent}%";
                format-icons = [
                  ""
                  ""
                  ""
                ];
                on-scroll-up = "brightnessctl set 1%+";
                on-scroll-down = "brightnessctl set 1%-";
                min-length = 6;
              };

              "group/audio" = {
                orientation = "inherit";
                modules = ["pulseaudio" "pulseaudio/slider"];
                drawer = {};
              };
              "pulseaudio/slider" = {
                min = 0;
                max = 100;
                orientation = "horizontal";
              };
              pulseaudio = {
                format = "{icon}  {volume}%  {format_source}";
                format-muted = "ﱝ Muted";
                format-source = "";
                format-source-muted = "";
                #TODO: on-click = "/home/main/.config/hypr/scripts/volume_ctl.sh mute";
                scroll-step = 1;
                format-icons = {
                  headphone = "";
                  hands-free = "";
                  headset = "";
                  phone = "";
                  portable = "";
                  car = "";
                  default = ["" "" "墳" ""];
                };
              };

              "group/power" = {
                orientation = "inherit";
                drawer = {};
                modules = [
                  "custom/power"
                  "custom/quit"
                  "custom/lock"
                  "custom/reboot"
                  "idle_inhibitor"
                ];
              };
              "custom/quit" = {
                format = "󰗼";
                tooltip = false;
                on-click = "fish -c 'set -Ux HYPRLAND_SHELL_EXIT 1; hyprctl dispatch exit none";
              };
              "custom/lock" = {
                format = "󰍁";
                tooltip = false;
                on-click = "hyprlock --immediate";
              };
              "custom/reboot" = {
                format = "󰜉";
                tooltip = false;
                on-click = "systemctl reboot";
              };
              "custom/power" = {
                format = "";
                tooltip = false;
                on-click = "systemctl poweroff";
              };
              idle_inhibitor = {
                format = "{icon}";
                tooltip-format-activated = "idle inhibitor: {status}";
                tooltip-format-deactivated = "idle inhibitor: {status}";
                format-icons = {
                  activated = "";
                  deactivated = "";
                };
              };

              "hyprland/window".format = "{}";
              "hyprland/workspaces" = {
                disable-scroll = true;
                all-outputs = true;
                on-click = "activate";
              };
              "hyprland/language" = {
                format-en = "en-us";
                format-en-colemak = "clmk";
              };

              /*
                "custom/power" = {
                exec = "cat /sys/class/power_supply/BAT1/power_now 2> /dev/null | numfmt --to-unit=1000000 --format %.3fW";
                interval = 5;
                format = "{}";
              };
              */
              /*
                "custom/keyboard" = {
                exec = "cat /home/main/.kbd-pipe";
                restart-interval = {
                };
                format = " {}";
              };A
              */
              /*
                "custom/media" = {
                format = "{icon}{}";
                return-type = "json";
                format-icons = {
                  Playing = " ";
                  Paused = " ";
                };
                max-length = 70;
                exec = "playerctl -a metadata --format '{\"text\": \"{{playerName}}: {{artist}} ~ {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
                on-click = "playerctl play-pause";
              };
              */

              mpris = {
                format = "{player_icon} {dynamic}";
                format-paused = "{status_icon} <i>{dynamic}</i>";
                player-icons.default = "▶";
                status-icons = {
                  paused = "⏸";
                };
              };

              privacy = {
                icon-spacing = 4;
                icon-size = 18;
                transition-duration = 250;
                modules = [
                  {
                    type = "screenshare";
                    tooltip = true;
                    tooltip-icon-size = 24;
                  }
                  /*
                    {
                    type = "audio-out";
                    tooltip = true;
                    tooltip-icon-size = 24;
                  }
                  */
                  {
                    type = "audio-in";
                    tooltip = true;
                    tooltip-icon-size = 24;
                  }
                ];
              };

              systemd-failed-units.format = "✗ {nr_failed}";

              bluetooth = {
                format = " {status}";
                format-connected = " {device_alias}";
                format-connected-battery = " {device_alias} {device_battery_percentage}%";
                tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
                tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
                tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
                tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
              };
              tray = {
                icon-size = 13;
                spacing = 10;
              };
              battery = {
                states = {
                  good = 95;
                  warning = 30;
                  critical = 20;
                };
                format = "{icon} {capacity}% -{power}W";
                format-charging = " {capacity}% {power}W";
                format-plugged = " {capacity}% {power}W";
                format-alt = "{time} {icon}";
                format-icons = ["" "" "" "" "" "" "" "" "" "" ""];
              };
              clock = {
                format = " {:%H:%M:%S   %Y-%m-%d}";
                tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
                interval = 1;
              };
              network = {
                format-wifi = "直{essid}";
                format-ethernet = " eth";
                format-linked = "{ifname} (No IP) ";
                format-disconnected = "睊 Disconnected";
                tooltip-format-wifi = "Signal Strength: {signalStrength}% | Down Speed: {bandwidthDownBits}, Up Speed: {bandwidthUpBits}";
                #TODO: on-click = "wifi4wofi";
              };
              user = {
                format = "↑{work_H}:{work_M}:{work_S}";
                interval = 1;
                height = 30;
                width = 30;
                icon = true;
              };
              cava = {
                cava_config = "$XDG_CONFIG_HOME/cava/config";
                framerate = 30;
                bars = 8;
                bar_delimiter = 0;
                format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
                actions = {
                  on-click-right = "mode";
                };
              };
            };
          };
          style = ''
            * {
                border: none;
                border-radius: 0;
                font-family: MesloLGS Nerd Font;
                font-weight: bold;
                font-size: 13px;
                min-height: 0;
            }

            window#waybar {
                background: rgba(30, 34, 42, 0.5);
                color: #b4befe;
                border: 1.5px solid;
                border-radius: 10px;
                border-image: linear-gradient(to bottom right, #33ccff, #cc33ff) 1;
                /*border-color: rgba(51, 204, 255, 0.8); #33ccff;*/
            }

            tooltip {
                background: rgba(30, 34, 42, 0.7); /*#1e1e2e;*/
                border-radius: 10px;
                border-width: 2px;
                border-style: solid;
                border-color: #11111b;
            }

            #workspaces button {
                padding: 5px;
                color: #313244;
                margin-right: 5px;
            }

            #workspaces button.active {
                color: #a6adc8;
            }

            #workspaces button.focused {
                color: #a6adc8;
                background: #eba0ac;
                border-radius: 10px;
            }

            #workspaces button.urgent {
                color: #11111b;
                background: #a6e3a1;
                border-radius: 10px;
            }

            #workspaces button:hover {
                background: #11111b;
                color: #cdd6f4;
                border-radius: 10px;
            }

            #mpris {
              font-size: 10px;
            }

            #custom-power,
            #bluetooth,
            #user,
            #cpu,
            #custom-keyboard,
            #custom-power,
            #mpris,
            #window,
            #clock,
            #battery,
            #pulseaudio,
            #network,
            #workspaces,
            #language,
            #tray,
            #privacy,
            #systemd-failed-units,
            #backlight {
                /*background: rgba(30, 30, 40, 0.25); *//*#1e1e2e;*/
                background: rgba(0, 0, 0, 0.25);
                padding: 0px 10px;
                margin: 8px 3px;
                /*border: 1px solid rgba(51, 204, 255, 0.5); #33ccff;*/
                border-radius: 5px;
                min-width: 20px;
            }

            #custom-quit,
            #custom-lock,
            #custom-reboot,
            #idle_inhibitor,
            #temperature,
            #memory,
            #disk {
              padding: 0px 10px;
              margin: 7px 3px;
              border-radius: 5px;
              min-width: 10px;
            }

            #systemd-failed-units
            {
                color: #FF2040;
            }

            #battery
            {
                color: #81D9FF;
            }

            #pulseaudio,
            #backlight,
            #clock,
            #cpu
            {
                color: #89b4fa;
            }

            #bluetooth,
            #user,
            #temperature
            {
                color: #b4befe;
            }

            #network,
            #memory
            {
                color: #bbaaf7;
            }

            #custom-media,
            #disk
            {
                color: #cba6fa;
            }

            #backlight-slider slider,
            #pulseaudio-slider slider {
              min-height: 7px;
              min-width: 0px;
              opacity: 0;
              border-top-left-radius: 7px;
              border-bottom-right-radius: 7px;
              background-image: linear-gradient(to bottom right, #33ccff, #cc33ff);
              border: none;
              box-shadow: none;
            }
            #backlight-slider trough,
            #pulseaudio-slider trough {
              min-height: 6px;
              min-width: 80px;
              border-top-left-radius: 6px;
              border-bottom-right-radius: 6px;
              background-color: black;
            }
            #backlight-slider highlight,
            #pulseaudio-slider highlight {
              min-width: 6px;
              border-top-left-radius: 6px;
              border-bottom-right-radius: 6px;
              background-image: linear-gradient(to bottom right, #cc33ff, #33ccff);
            }
          '';
        };
      })
      config.cfg.core.users;
  };
}
