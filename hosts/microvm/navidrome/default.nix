{
  config,
  configLib,
  lib,
  pkgs,
  unstable,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;
in {
  environment.etc."feishin.env".text = "SERVER_URL=https://navidrome.${domain}";
  svc.watchtower.enable = true;
  svc.docker.feishin = {
    enable = true;
    compose = ./docker-compose.yml;
    envFile = "/etc/feishin.env";
  };

  systemd.services.navidrome.serviceConfig = {
    LoadCredential = configLib.toCredential ["rendered/config.json"]; # sops template defined in meta.nix
    ExecStart = mkForce ''
      ${getExe pkgs.navidrome} --configfile /run/credentials/navidrome.service/rendered-config.json
    '';
  };

  services.navidrome = {
    enable = true;

    user = "vm-navidrome";
    group = "vm-navidrome";

    openFirewall = true;

    settings = {
      MusicFolder = "/music";
      DataFolder = "/data/data";
      CacheFolder = "/data/cache";
    };
  };
}
