{
  lib,
  pkgs,
  ...
}:
with lib; let
  #compose = ./docker-compose.yml;
in {
  #cfg.microvm.services.watchtower.enable = true;
  /*
    virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [docker-compose];
  systemd.services.foundryvtt = {
    script = ''
      docker-compose --env-file /secrets/rendered/env -f ${compose} up
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    path = [pkgs.docker-compose];
  };
  */

  environment.systemPackages = with pkgs; [nodejs];

  systemd.services.fvtt = {
    enable = true;
    script = ''
      cd /data/fvtt
      ${pkgs.nodejs}/bin/node resources/app/main.js --dataPath=/data/data
    '';
    wantedBy = ["multi-user.target"];
    after = [];
    path = ["/data"];
  };
}
