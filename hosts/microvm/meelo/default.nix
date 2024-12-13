{
  config,
  lib,
  pkgs,
  ...
}: with lib; {
  #environment.etc."meelo/env".source = mkForce "/secrets/rendered/env"; # sops template defined in meta.nix
  #environment.etc."meelo/settings.json".source = mkForce "/secrets/rendered/settings.json"; # mounted as docker volume instead

  cfg.microvm.services.watchtower.enable = true;
  cfg.microvm.services.docker.${config.networking.hostName} = {
    enable = true;
    compose = ./docker-compose.yml;
    envFile = "/secrets/rendered/env";
  };
}
