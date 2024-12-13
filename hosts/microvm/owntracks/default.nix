{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms;
  inherit (config.networking) domain;
in {
  environment.etc."owntracks/fe-config.js".text = ''
    window.owntracks = window.owntracks || {};
    window.owntracks.config = {
      api: {
        baseUrl: "https://owntracks.${domain}",
      },
      ignorePingLocation: true,
    };
  '';

  svc.watchtower.enable = true;
  svc.docker.${config.networking.hostName} = {
    enable = true;
    compose = ./docker-compose.yml;
  };
}
