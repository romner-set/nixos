{
  lib,
  configLib,
  config,
  pkgs,
  ...
}:
with lib; let
  users = config.cfg.core.users;
in {
  options.cfg.core.users = mkOption {
    type = with types;
      attrsOf (submodule ({name, ...}: {
        options = {
          enable = mkEnableOption "user ${name}";
          name = mkOption {
            type = types.passwdEntry types.str;
            default = name;
          };
          sshKeys = mkOption {
            type = types.listOf types.singleLineStr;
            default = [];
          };
          home = {
            path = mkOption {
              type = types.path;
              default = "/home/${name}";
            };
            stateVersion = mkOption {
              type = types.str;
              default = config.system.stateVersion;
            };
          };
        };
      }));
    default = {};
  };

  config = with lib.attrsets;
    mkIf (length (mapAttrsToList (n: v: v.enable) users) > 0) {
      security.sudo.enable = lib.mkForce true;
      security.sudo.wheelNeedsPassword = false;

      nix.settings.allowed-users = lib.mapAttrsToList (name: _: name) users;

      # For some reason coredumps aren't disabled by default
      systemd.user.extraConfig = "DefaultLimitCORE=0";

      users.users =
        attrsets.mapAttrs (name: cfg: {
          isNormalUser = true;
          extraGroups = ["wheel" "adbusers" "dialout"];
          shell = pkgs.fish;
          #packages = with pkgs; [];
          hashedPasswordFile = "/home/${name}/.passwd"; #TODO: sops-nix declarative?
          openssh.authorizedKeys.keys = cfg.sshKeys or config.svc.ssh.keys;
        })
        users;
    };
}
