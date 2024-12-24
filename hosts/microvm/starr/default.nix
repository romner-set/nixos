{
  config,
  configLib,
  lib,
  pkgs,
  ...
}: let
  user = "vm-starr";
  group = "vm-starr";
in {
  imports = configLib.scanPath ./modules;

  services = {
    radarr = {
      inherit user group;
      enable = true;
      dataDir = "/data/radarr";
    };
    sonarr = {
      inherit user group;
      enable = true;
      dataDir = "/data/sonarr";
    };
    lidarr = {
      inherit user group;
      enable = true;
      dataDir = "/data/lidarr";
    };
    flaresolverr = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/issues/332776
      package = pkgs.nur.repos.xddxdd.flaresolverr-21hsmw;
    };
    jellyseerr = {
      enable = true;
    };
  };

  util-nixarr.services = {
    bazarr = {
      inherit user group;
      enable = true;
      dataDir = "/data/bazarr";
    };
    prowlarr = {
      inherit user group;
      enable = true;
      dataDir = "/data/prowlarr";
    };
  };

  systemd.services.jellyseer = {
    environment.CONFIG_DIRECTORY = "/data/jellyseerr";
    serviceConfig = {
      BindPaths = [ "/data/jellyseerr" ];
      User = user;
      Group = group;
      DynamicUser = lib.mkForce false;
    };
  };
}
