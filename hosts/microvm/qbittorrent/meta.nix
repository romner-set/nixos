cfg: {
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
      tag = "qbittorrent-data";
      source = "/data/qbittorrent";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "qbittorrent-docker";
      source = "/vm/qbittorrent/docker";
      mountPoint = "/var/lib/docker";
    }
  ];
}
