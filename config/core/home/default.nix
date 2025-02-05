{
  config,
  configLib,
  lib,
  ...
}: let
  cfg = config.cfg.core.users;
in {
  imports = configLib.scanPath ./.;

  home-manager.users =
    (lib.attrsets.mapAttrs (name: _: {
      home.username = name;
      home.homeDirectory = lib.mkForce cfg.${name}.home.path;
      home.stateVersion = cfg.${name}.home.stateVersion;
    })
    config.cfg.core.users) // {
      root.home = {
        username = "root";
        homeDirectory = lib.mkForce "/root";
        stateVersion = config.system.nixos.release;
      };
    };
}
