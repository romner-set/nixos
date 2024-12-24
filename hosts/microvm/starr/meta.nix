{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 34;
  # NOTE: configuring radarr & sonarr from scratch is torture
  # just use https://recyclarr.dev/wiki/guide-configs/#remux-web-1080p
  # & https://recyclarr.dev/wiki/guide-configs/#web-1080p-v4
  webPorts = [7878 8989 8686 6767 9696 5055];

  #vHosts.radarr.authPolicy = "bypass"; # recyclarr
  vHosts.radarr.locations."/" = {
    proto = "http";
    port = 7878;
  };

  #vHosts.sonarr.authPolicy = "bypass"; # recyclarr
  vHosts.sonarr.locations."/" = {
    proto = "http";
    port = 8989;
  };

  vHosts.lidarr.locations."/" = {
    proto = "http";
    port = 8686;
  };

  vHosts.bazarr.locations."/" = {
    proto = "http";
    port = 6767;
  };

  vHosts.prowlarr.locations."/" = {
    proto = "http";
    port = 9696;
  };

  vHosts.jellyseerr.locations."/" = {
    proto = "http";
    port = 5055;
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "starr-data";
      source = "/vm/starr";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "starr-media";
      source = "/data/media";
      mountPoint = "/media";
    }
  ];
}
