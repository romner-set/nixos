{
  config,
  lib,
  pkgs,
  ...
}: with lib; {
  svc.watchtower.enable = true;
  svc.docker.${config.networking.hostName} = {
    enable = true;
    compose = ./docker-compose.yml;
    envFile = "/secrets/rendered/env";
  };
}
