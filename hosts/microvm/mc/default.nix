{
  config,
  lib,
  pkgs,
  ...
}: with lib; {
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [];

  #cfg.microvm.services.watchtower.enable = true;
  cfg.microvm.services.docker = {
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
