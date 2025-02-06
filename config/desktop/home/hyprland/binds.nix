{
  lib,
  pkgs,
  ...
}:
with lib; let
  tofi = import ./scripts/tofi.nix pkgs;
  functionKeys = import ./scripts/function-keys.nix pkgs;
in ''
  $mainMod = SUPER

  # App binds
  bind = $mainMod, T, exec, kitty -1
  bind = $mainMod, W, exec, vivaldi --enable-features=UseOzonePlatform --ozone-platform=wayland

  # Control stuff
  binde = $mainMod, Q, killactive
  bind = $mainMod, M, exit
  bind = $mainMod, K, exec, fish -c 'set -Ux HYPRLAND_SHELL_EXIT 1; hyprctl dispatch exit none'
  bind = $mainMod, F, togglefloating
  bind = $mainMod, P, pseudo
  bind = $mainMod, L, togglesplit
  bind = $mainMod, X, exec, hyprlock --immediate

  bind = $mainMod, R, exec, tofi-drun | xargs uwsm app --
  bind = $mainMod, Z, exec, sh ${tofi.powermenu}
  bind = $mainMod, C, exec, bash ${tofi.calc}
  bind = $mainMod, V, exec, kitty -1 --class clipse -e 'clipse'

  bindl = ,switch:on:Lid Switch, exec, hyprlock --immediate

  # Brightness
  bindel = ,198, exec, sh ${functionKeys.brightness} 25%-
  bindel = SUPER,33, exec, sh ${functionKeys.brightness} +25%
  bindel = ,232, exec, sh ${functionKeys.brightness} 5%-
  bindel = ,233, exec, sh ${functionKeys.brightness} +5%
  bindel = SHIFT,198, exec, sh ${functionKeys.brightness} 50%-
  bindel = SHIFT,133, exec, sh ${functionKeys.brightness} +50%
  bindel = SHIFT,232, exec, sh ${functionKeys.brightness} 1-
  bindel = SHIFT,233, exec, sh ${functionKeys.brightness} +1

  # Volume
  bindel = , XF86AudioMute, exec, fish ${functionKeys.mute}
  bindel = SHIFT, XF86AudioMute, exec, fish ${functionKeys.volumeLimit}
  bindel = , XF86AudioLowerVolume, exec, fish ${functionKeys.volume} 5%-
  bindel = , XF86AudioRaiseVolume, exec, fish ${functionKeys.volume} 5%+
  bindel = SHIFT, XF86AudioLowerVolume, exec, fish ${functionKeys.volume} 1%-
  bindel = SHIFT, XF86AudioRaiseVolume, exec, fish ${functionKeys.volume} 1%+
  bindel = $mainMod, XF86AudioLowerVolume, exec, fish ${functionKeys.volume} 25%-
  bindel = $mainMod, XF86AudioRaiseVolume, exec, fish ${functionKeys.volume} 25%+
  bindel = CONTROL, XF86AudioLowerVolume, exec, fish ${functionKeys.volume} 0.1%-
  bindel = CONTROL, XF86AudioRaiseVolume, exec, fish ${functionKeys.volume} 0.1%+

  bindel = $mainMod, SPACE, exec, playerctl play-pause & ${functionKeys.media}
  bindel = , XF86AudioPlay, exec, playerctl play-pause & ${functionKeys.media}
  bindel = , XF86AudioNext, exec, playerctl next & ${functionKeys.media}
  bindel = , XF86AudioPrev, exec, playerctl previous & ${functionKeys.media}
  bindel = SHIFT, XF86AudioNext, exec, playerctl position 10+ && dunstify "Skipped 10s"
  bindel = SHIFT, XF86AudioPrev, exec, playerctl position 10- && dunstify "Rewinded 10s"

  # Resize windows with mainMod + CONTROL + arrow keys
  binde = $mainMod CONTROL, left, resizeactive, -50 0
  binde = $mainMod CONTROL, right, resizeactive, 50 0
  binde = $mainMod CONTROL, up, resizeactive, 0 -50
  binde = $mainMod CONTROL, down, resizeactive, 0 50

  # Move windows with mainMod + numpad
  binde = $mainMod, code:84, fullscreen
  # Tiled
  binde = $mainMod, code:83, movewindow, l
  binde = $mainMod, code:85, movewindow, r
  binde = $mainMod, code:80, movewindow, u
  binde = $mainMod, code:87, movewindow, d
  # Floating
  binde = $mainMod SHIFT, code:84, centerwindow
  binde = $mainMod, code:83, moveactive, -50 0
  binde = $mainMod, code:85, moveactive, 50 0
  binde = $mainMod, code:80, moveactive, 0 -50
  binde = $mainMod, code:88, moveactive, 0 50

  bind = $mainMod, code:91, pin, active # keypad dot

  # Move focus with mainMod + arrow keys
  binde = $mainMod, left, movefocus, l
  binde = $mainMod, right, movefocus, r
  binde = $mainMod, up, movefocus, u
  binde = $mainMod, down, movefocus, d

  # Switch workspaces with mainMod + SHIFT + arrows
  bind = $mainMod SHIFT, left, workspace, -1
  bind = $mainMod SHIFT, right, workspace, +1

  # Switch workspaces with mainMod + [0-9]
  ${concatMapStrings (i: "bind = $mainMod, ${toString (mod i 10)}, workspace, ${toString i}\n") (range 1 10)}

  # Move active window to a workspace with mainMod + SHIFT + [0-9]
  ${concatMapStrings (i: "bind = $mainMod SHIFT, ${toString (mod i 10)}, movetoworkspace, ${toString i}\n") (range 1 10)}

  # Move active window to a workspace with mainMod + SHIFT + scroll
  bind = $mainMod SHIFT, mouse_down, movetoworkspace, -1
  bind = $mainMod SHIFT, mouse_up, movetoworkspace, +1

  # Change monitors with mainMod + tab
  bind = $mainMod, 23, focusmonitor, +1

  # Scroll through workspaces with mainMod + scroll
  bind = $mainMod, mouse_down, workspace, -1
  bind = $mainMod, mouse_up, workspace, +1

  # Move/resize windows with mainMod + LMB/RMB and dragging
  bindm = $mainMod, mouse:272, movewindow
  bindm = $mainMod, mouse:273, resizewindow
''
