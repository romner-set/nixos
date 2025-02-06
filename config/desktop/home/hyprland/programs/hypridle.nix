{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.cfg.desktop.environment.hyprland;
in {
  /*
    options.cfg.desktop.environment.hyprland.services.hypridle = {
  };
  */

  config = lib.mkIf cfg.enable {
    home-manager.users =
      lib.attrsets.mapAttrs (name: _: {
        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              unlock_cmd = "pkill hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = "hyprctl dispatch dpms on";
            };

            listener = [
              {
                timeout = 300; # 5min
                on-timeout = "brightnessctl -s set 10%";
                on-resume = "brightnessctl -r";
              }
              {
                timeout = 360; # 6min
                on-timeout = "loginctl lock-session";
              }
              {
                timeout = 600; # 10min
                on-timeout = "systemctl suspend";
              }
            ];
          };
        };
      })
      config.cfg.core.users;
  };
}
