{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = ["8286ac0e47ef4d65"];

  svc.watchtower.enable = true;
  svc.docker = {
    mc = {
      enable = true;
      compose = ./docker-compose.yml;
      envFile = "/secrets/rendered/env";
    };
    rw = {
      enable = false;
      compose = "/rw/docker-compose.yml";
    };
  };

  networking.firewall.enable = false;
}
