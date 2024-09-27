{...}: {
  id = 17;

  webPorts = [8080];
  locations."/" = {
    proto = "http";
    port = 8080;
  };
  subdomain = "qb";

  shares = [
    {
      proto = "virtiofs";
      tag = "qbittorrent-config";
      source = "/vm/qbittorrent/config";
      mountPoint = "/config";
    }
    {
      proto = "virtiofs";
      tag = "qbittorrent-games";
      source = "/data/games";
      mountPoint = "/data/games";
    }
    {
      proto = "virtiofs";
      tag = "qbittorrent-media";
      source = "/data/media";
      mountPoint = "/data/media";
    }
    {
      proto = "virtiofs";
      tag = "qbittorrent-misc";
      source = "/misc/qbittorrent";
      mountPoint = "/misc";
    }
    {
      proto = "virtiofs";
      tag = "qbittorrent-docker";
      source = "/vm/qbittorrent/docker";
      mountPoint = "/var/lib/docker";
    }
  ];
}
