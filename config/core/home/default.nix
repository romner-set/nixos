{
  config,
  configLib,
  lib,
  ...
}: with lib; let
  cfg = config.cfg.core.users;
in {
  imports = configLib.scanPath ./.;

  options.cfg.core.home.enable = mkOption {
    type = types.bool;
    default = true;
  };

  config = mkIf config.cfg.core.home.enable {
    home-manager.users =
      (attrsets.mapAttrs (name: _: {
        home.username = name;
        home.homeDirectory = mkForce cfg.${name}.home.path;
        home.stateVersion = cfg.${name}.home.stateVersion;
      })
      config.cfg.core.users) // {
        root.home = {
          username = "root";
          homeDirectory = mkForce "/root";
          stateVersion = config.system.nixos.release;
        };
      };
  };
}
