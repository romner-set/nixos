{
  config,
  configLib,
  lib,
  ...
}: let
  cfg = config.cfg.core.users;
in {
  imports = configLib.scanPaths [./core ./optional];

  home-manager.users =
    lib.attrsets.mapAttrs (name: _: {
      home.username = "${name}";
      home.homeDirectory = lib.mkForce cfg.${name}.home.path;
      home.stateVersion = cfg.${name}.home.stateVersion;

      # link the configuration file in current directory to the specified location in home directory
      # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

      # link all files in `./scripts` to `~/.config/i3/scripts`
      # home.file.".config/i3/scripts" = {
      #   source = ./scripts;
      #   recursive = true;   # link recursively
      #   executable = true;  # make all files executable
      # };

      # encode the file content in nix configuration file directly
      # home.file.".xxx".text = ''
      #     xxx
      # '';
    })
    config.cfg.core.users;
}
