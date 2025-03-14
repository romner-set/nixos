pkgs: rec {
  powermenu = pkgs.writeText "tofi-powermenu.sh" ''
    case $(printf "%s\n" "shutdown" "reboot" "suspend" "hibernate" "cancel" | tofi --ascii-input true $@) in
     "shutdown")
      systemctl poweroff
      ;;
     "reboot")
      systemctl reboot
      ;;
     "suspend")
      systemctl suspend
      ;;
     "hibernate")
      systemctl hibernate
      ;;
    esac
  '';

  calc = pkgs.writeText "tofi-calc.bash" ''
    XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
    tmp_dir="$XDG_CACHE_HOME/tofi-calc"
    tmp_path="$tmp_dir/history"
    is_history_value=false
    max_age_days=365

    mkdir -p "$tmp_dir"
    if [ ! -f "$tmp_path" ]; then
        touch "$tmp_path"
    fi

    # Clean up old entries
    find "$tmp_dir" -type f -mtime +$max_age_days -delete

    # Input operation
    operation=$(cat $tmp_path | tofi --prompt-text="calc: " --require-match=false)

    # Exit if no operation provided
    if [ -z "$operation" ]; then
     #notify-send "No operation provided." "Please provide a valid operation."
     exit
    fi

    # Remove operation when using history values
    if [[ "$operation" == *"="* ]]; then
     operation=$(echo "$operation" | cut -d "=" -f 2)
     is_history_value=true
    fi

    # Calculate the result and delete new line or backslash characters
    result=$(fish -c "math '$operation'")

    # Exit if invalid operation
    if [ -z "$result" ]; then
     notify-send "Invalid operation." "Please provide a valid operation."
     exit
    fi

    # Save the operation and result to history
    if [ "$is_history_value" = false ]; then
     if ! grep -q "$operation = $result" "$tmp_path"; then
         temp_file=$(mktemp)
         echo "$operation = $result" > "$temp_file"
         cat "$tmp_path" >> "$temp_file"
         mv "$temp_file" "$tmp_path"
     fi
    fi

    # Copy the result to the clipboard
    echo "$result" | wl-copy --trim-newline

    notify-send "Result: $result" "Result copied to clipboard."
  '';
}
