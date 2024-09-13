#!/usr/bin/env sh
nix-collect-garbage --delete-old
printf "%s" "Press any key to continue..."
read ans
/run/current-system/bin/switch-to-configuration boot
