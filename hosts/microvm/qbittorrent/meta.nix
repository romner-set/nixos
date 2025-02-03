{...}: {
  id = 17;

  tcpPorts = [8080];

  vHosts.qb = {
    locations."/" = {
      proto = "http";
      port = 8080;
    };
  };

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
      source = "/data/media/qbittorrent";
      mountPoint = "/data/media";
    }
    {
      proto = "virtiofs";
      tag = "qbittorrent-misc";
      source = "/data/misc";
      mountPoint = "/data/misc";
    }
    {
      proto = "virtiofs";
      tag = "qbittorrent-docker";
      source = "/vm/qbittorrent/docker";
      mountPoint = "/var/lib/docker";
    }
  ];
}
