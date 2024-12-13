{
  config,
  lib,
  pkgs,
  ...
}: with lib; {
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [];

  #svc.watchtower.enable = true;
  svc.docker = {
    mc = {
      enable = false;
      compose = ./docker-compose.yml;
    };
    rw = {
      enable = false;
      compose = "/rw/docker-compose.yml";
    };
  };
}
