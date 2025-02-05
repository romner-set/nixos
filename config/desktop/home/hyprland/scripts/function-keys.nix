pkgs: {
  brightness = pkgs.writeText "brightness.sh" ''
    brightnessctl s $1
    brightness=$(brightnessctl g)
    dunstify -a "BRIGHTNESS" "Brightness changed to $(($brightness*100/255))% [''${brightness}]" -h int:value:"$(($brightness*100/255))" -i display-brightness-symbolic -r 2593 -u normal -t 2000
  '';

  volume = pkgs.writeText "volume.fish" ''
    #!/bin/fish
    set -ge SAFE_VOLUME
    wpctl set-volume -l 0"$SAFE_VOLUME" @DEFAULT_AUDIO_SINK@ $argv

    set volume (math (wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}') \* 100)
    dunstify -a "VOLUME" "Volume changed to $volume%" -h int:value:"$volume" -i audio-volume-high-symbolic -r 2594 -u (test $volume -le 100; and echo normal; or echo critical) -t 2000
  '';

  volumeLimit = pkgs.writeText "volume-limit.fish" ''
    set -ge SAFE_VOLUME

    if set -q SAFE_VOLUME
      set -Ue SAFE_VOLUME
    else
      set -Ux SAFE_VOLUME 1
      set vol (wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
      test $vol -gt 1 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 1
    end

    dunstify -a "VOLUME" "Volume limit $(set -q SAFE_VOLUME; and echo en; or echo dis)abled" -i audio-volume-high-symbolic -r 2594 -u (set -q SAFE_VOLUME; and echo normal; or echo critical) -t 2000
  '';

  mute = pkgs.writeText "mute.fish" ''
    set s "$(string match -q -- "*[MUTED]" (wpctl get-volume @DEFAULT_AUDIO_SINK@); echo $status)"
    wpctl set-mute @DEFAULT_SINK@ $s

    dunstify -a "VOLUME" "$(test $s = 1; and echo M; or echo Unm)uted" -i audio-volume-high-symbolic -r 2594 -u $(test $s = 1; and echo normal; or echo critical) -t 2000
  '';

  media = pkgs.writeText "media.fish" ''
    set progress (math (playerctl metadata -f 'round({{position}}*100/{{mpris:length}})'))

    dunstify -a "MEDIA" (playerctl metadata -f '{{artist}} ~ {{title}}
    {{status}} @{{playerName}} [{{duration(position)}}/{{duration(mpris:length)}}]') -h int:value:"$progress" -i audio-volume-high-symbolic -r 2596 -u normal -t 5000
  '';
}
