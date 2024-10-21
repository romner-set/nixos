{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  compose = ./docker-compose.yml;
in {
  cfg.microvm.services.watchtower.enable = true;

  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [docker-compose];
  systemd.services.kitchenowl = {
    script = ''
      docker-compose --env-file /secrets/rendered/env -f ${compose} up
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    path = [pkgs.docker-compose];
  };
}
