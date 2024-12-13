{
  config,
  lib,
  pkgs,
  ...
}: with lib; {
  cfg.microvm.services.watchtower.enable = true;
  cfg.microvm.services.docker.${config.networking.hostName} = {
    enable = true;
    compose = ./docker-compose.yml;
  };
}
