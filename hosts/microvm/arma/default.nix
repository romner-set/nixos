{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  services.teamspeak3 = {
    enable = true;
    dataDir = "/ts3";
  };

  svc.watchtower.enable = true;
  svc.docker.${config.networking.hostName} = {
    enable = true;
    compose = ./docker-compose.yml;
    envFile = "/secrets/rendered/env";
  };
}
