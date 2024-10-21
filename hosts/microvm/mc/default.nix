{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  compose = ./docker-compose.yml;
in {
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [];

  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [docker-compose];
  systemd.services.rw = {
    enable = true;
    script = ''
      cd /rw
      docker-compose up
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    path = [pkgs.docker-compose];
  };
  systemd.services.mc = {
    enable = false;
    script = ''
      docker-compose -f ${compose} up
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    path = [pkgs.docker-compose];
  };
}
