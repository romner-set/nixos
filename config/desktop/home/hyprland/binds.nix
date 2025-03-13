{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  tofi = import ./scripts/tofi.nix pkgs;
  functionKeys = import ./scripts/function-keys.nix pkgs;

  cfg = config.cfg.desktop.environment.hyprland.binds;
in ''
  $mainMod = SUPER

  # App binds
  bind = $mainMod, T, exec, kitty -1
  bind = $mainMod, W, exec, vivaldi --enable-features=UseOzonePlatform --ozone-platform=wayland
  bind = $mainMod, N, exec, nautilus

  # Control stuff
  bindp = $mainMod, Q, killactive
  bindp = $mainMod SHIFT, Q, forcekillactive
  bindp = $mainMod, M, exit
  bindp = $mainMod, K, exec, fish -c 'set -Ux HYPRLAND_SHELL_EXIT 1; hyprctl dispatch exit none'
  bindp = $mainMod, F, togglefloating
  bindp = $mainMod, P, pseudo
  bindp = $mainMod, L, togglesplit
  bindp = $mainMod, X, exec, hyprlock --immediate
  bindp = $mainMod SHIFT, F, fullscreen
  bindp = ,Print, exec, hyprshot -m region

  bindp = $mainMod, R, exec, tofi-drun | xargs uwsm app --
  bindp = $mainMod, Z, exec, sh ${tofi.powermenu}
  bindp = $mainMod, C, exec, bash ${tofi.calc}
  bindp = $mainMod, V, exec, kitty -1 --class clipse -e 'clipse'

  bindlp = ,switch:on:Lid Switch, exec, hyprlock --immediate

  # Brightness
  bindelp = ,232, exec, sh ${functionKeys.brightness} ${cfg.brightnessSteps.normal}-
  bindelp = ,233, exec, sh ${functionKeys.brightness} +${cfg.brightnessSteps.normal}
  bindelp = SHIFT,232, exec, sh ${functionKeys.brightness} ${cfg.brightnessSteps.small}-
  bindelp = SHIFT,233, exec, sh ${functionKeys.brightness} +${cfg.brightnessSteps.small}
  bindelp = $mainMod,232, exec, sh ${functionKeys.brightness} ${cfg.brightnessSteps.large}-
  bindelp = $mainMod,233, exec, sh ${functionKeys.brightness} +${cfg.brightnessSteps.large}
  bindelp = CONTROL,232, exec, sh ${functionKeys.brightness} ${cfg.brightnessSteps.precise}-
  bindelp = CONTROL,233, exec, sh ${functionKeys.brightness} +${cfg.brightnessSteps.precise}

  # Volume
  bindelp = , XF86AudioMute, exec, fish ${functionKeys.mute}
  bindelp = SHIFT, XF86AudioMute, exec, fish ${functionKeys.volumeLimit}
  bindelp = , XF86AudioLowerVolume, exec, fish ${functionKeys.volume} ${cfg.volumeSteps.normal}-
  bindelp = , XF86AudioRaiseVolume, exec, fish ${functionKeys.volume} ${cfg.volumeSteps.normal}+
  bindelp = SHIFT, XF86AudioLowerVolume, exec, fish ${functionKeys.volume} ${cfg.volumeSteps.small}-
  bindelp = SHIFT, XF86AudioRaiseVolume, exec, fish ${functionKeys.volume} ${cfg.volumeSteps.small}+
  bindelp = $mainMod, XF86AudioLowerVolume, exec, fish ${functionKeys.volume} ${cfg.volumeSteps.large}-
  bindelp = $mainMod, XF86AudioRaiseVolume, exec, fish ${functionKeys.volume} ${cfg.volumeSteps.large}+
  bindelp = CONTROL, XF86AudioLowerVolume, exec, fish ${functionKeys.volume} ${cfg.volumeSteps.precise}-
  bindelp = CONTROL, XF86AudioRaiseVolume, exec, fish ${functionKeys.volume} ${cfg.volumeSteps.precise}+

  bindelp = $mainMod, SPACE, exec, playerctl play-pause & ${functionKeys.media}
  bindelp = , XF86AudioPlay, exec, playerctl play-pause & ${functionKeys.media}
  bindelp = , XF86AudioNext, exec, playerctl next & ${functionKeys.media}
  bindelp = , XF86AudioPrev, exec, playerctl previous & ${functionKeys.media}
  bindelp = SHIFT, XF86AudioNext, exec, playerctl position 10+ && dunstify "Skipped 10s"
  bindelp = SHIFT, XF86AudioPrev, exec, playerctl position 10- && dunstify "Rewinded 10s"

  # Resize windows with mainMod + CONTROL + arrow keys
  bindep = $mainMod CONTROL, left, resizeactive, -50 0
  bindep = $mainMod CONTROL, right, resizeactive, 50 0
  bindep = $mainMod CONTROL, up, resizeactive, 0 -50
  bindep = $mainMod CONTROL, down, resizeactive, 0 50

  # Move windows with mainMod + numpad
  bindp = $mainMod, code:84, fullscreen
  # Tiled
  bindep = $mainMod, code:83, movewindow, l
  bindep = $mainMod, code:85, movewindow, r
  bindep = $mainMod, code:80, movewindow, u
  bindep = $mainMod, code:87, movewindow, d
  # Floating
  bindp = $mainMod SHIFT, code:84, centerwindow
  bindep = $mainMod, code:83, moveactive, -50 0
  bindep = $mainMod, code:85, moveactive, 50 0
  bindep = $mainMod, code:80, moveactive, 0 -50
  bindep = $mainMod, code:88, moveactive, 0 50

  bindp = $mainMod, code:91, pin, active # keypad dot

  # Move focus with mainMod + arrow keys
  bindep = $mainMod, left, movefocus, l
  bindep = $mainMod, right, movefocus, r
  bindep = $mainMod, up, movefocus, u
  bindep = $mainMod, down, movefocus, d

  # Switch workspaces with mainMod + SHIFT + arrows
  bindp = $mainMod SHIFT, left, workspace, -1
  bindp = $mainMod SHIFT, right, workspace, +1

  # Switch workspaces with mainMod + [0-9]
  ${concatMapStrings (i: "bindp = $mainMod, ${toString (mod i 10)}, workspace, ${toString i}\n") (range 1 10)}

  # Move active window to a workspace with mainMod + SHIFT + [0-9]
  ${concatMapStrings (i: "bindp = $mainMod SHIFT, ${toString (mod i 10)}, movetoworkspace, ${toString i}\n") (range 1 10)}

  # Move active window to a workspace with mainMod + SHIFT + scroll
  bindp = $mainMod SHIFT, mouse_down, movetoworkspace, -1
  bindp = $mainMod SHIFT, mouse_up, movetoworkspace, +1

  # Change monitors with mainMod + tab
  bindp = $mainMod, 23, focusmonitor, +1

  # Scroll through workspaces with mainMod + scroll
  bindp = $mainMod, mouse_down, workspace, -1
  bindp = $mainMod, mouse_up, workspace, +1

  # Move/resize windows with mainMod + LMB/RMB and dragging
  bindmp = $mainMod, mouse:272, movewindow
  bindmp = $mainMod, mouse:273, resizewindow
''
