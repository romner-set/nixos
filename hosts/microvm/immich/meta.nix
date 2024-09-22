cfg: {
  id = 16;

  webPorts = [2283];
  locations."/" = {
    proto = "http";
    port = 2283;
  };
  #authPolicy = "bypass";
  bypassAuthForLAN = true;

  shares = [
    {
      proto = "virtiofs";
      tag = "immich-secrets";
      source = "/run/secrets/vm/immich";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "immich-data";
      source = "/vm/immich/data";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "immich-docker";
      source = "/vm/immich/docker";
      mountPoint = "/var/lib/docker";
    }
  ];

  secrets = {
    "vm/immich/env" = {};
  };
}
