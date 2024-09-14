cfg: {
  id = 7;
  # NOTE: jellyfin doesn't have IPv6 enabled out of the box,
  # manually connect to the instance and enable it on setup
  webPorts = [8096];
  vcpu = cfg.defaults.vcpu.max;

  locations."/" = {
    proto = "http";
    port = 8096;
  };
  authPolicy = "bypass";

  shares = [
    {
      proto = "virtiofs";
      tag = "jellyfin-data";
      source = "/vm/jellyfin/data";
      mountPoint = "/var/lib/jellyfin";
    }
    {
      proto = "virtiofs";
      tag = "jellyfin-cache";
      source = "/vm/jellyfin/cache";
      mountPoint = "/var/cache/jellyfin";
    }
    {
      proto = "virtiofs";
      tag = "jellyfin-media";
      source = "/data/media";
      mountPoint = "/media";
    }
  ];
}
