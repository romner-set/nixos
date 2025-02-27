{
  lib,
  pkgs,
  config,
  configLib,
  ...
}:
with lib; let
  cfg = config.svc.docker;
in {
  imports = configLib.scanPath ./.;

  options.svc.docker = mkOption {
    type = with types;
      attrsOf (submodule ({name, ...}: {
        options = {
          enable = mkEnableOption "${name} docker service";
          name = mkOption {
            type = types.str;
            default = name;
          };

          compose = mkOption {
            type = types.path;
          };

          envFile = mkOption {
            type = types.str;
            default = "";
          };
        };
      }));
    default = {};
  };

  config = with lib.attrsets;
    mkIf (length (mapAttrsToList (n: v: v.enable) cfg) > 0) {
      virtualisation.docker.enable = true;
      environment.systemPackages = with pkgs; [docker-compose];

      systemd.services =
        attrsets.mapAttrs' (name: v: {
          inherit name;
          value = {
            script = ''
              docker-compose ${
                if v.envFile != ""
                then "--env-file ${v.envFile}"
                else ""
              } -f ${v.compose} up
            '';
            wantedBy = ["multi-user.target"];
            after = ["docker.service" "docker.socket"];
            path = [pkgs.docker-compose];
            serviceConfig.Restart = "always";
          };
        })
        cfg;
    };
}
