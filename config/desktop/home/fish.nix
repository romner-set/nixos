{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.cfg.desktop.home;
in {
  options.cfg.desktop.home.fish.enable = mkOption {
    type = types.bool;
    default = cfg.enable;
  };
  config = mkIf cfg.fish.enable {
    home-manager.users =
      attrsets.mapAttrs (name: _: {
        programs.fish = {
          enable = true;
          functions = {
            "ccat" = "highlight -O truecolor -s neon $argv";
            "icat" = "kitty icat";
            "iptables" = "sudo iptables $argv";
            "ip6tables" = "sudo ip6tables $argv";
            "nix" = "sudo nix $argv";
            "nixos-rebuild" = "sudo nixos-rebuild $argv";
            "mount" = "sudo mount $argv";
            "umount" = "sudo umount $argv";
          };
        };
      })
      config.cfg.core.users;
  };
}
