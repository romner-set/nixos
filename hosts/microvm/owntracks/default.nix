{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  compose = ./docker-compose.yml;
  inherit (config.networking) domain;
in {
  cfg.microvm.services.watchtower.enable = true;

  environment.etc."owntracks/fe-config.js".text = ''
    window.owntracks = window.owntracks || {};
    window.owntracks.config = {
      api: {
        baseUrl: "https://owntracks.${domain}",
      },
      ignorePingLocation: true,
    };
  '';

  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [docker-compose];
  systemd.services.owntracks = {
    script = ''
      docker-compose -f ${compose} up
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    path = [pkgs.docker-compose];
  };
}
