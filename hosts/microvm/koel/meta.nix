{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 5;

  webPorts = [8080];
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.high;

  vHosts.koel = {
    locations."/" = {
      proto = "http";
      port = 8080;
    };
    authPolicy = "bypass";
    expectedMaxResponseTime = 500; # avg 256-267
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "koel-secrets";
      source = "/run/secrets/vm/koel";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "koel-data";
      source = "/vm/koel/data";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "koel-docker";
      source = "/vm/koel/docker";
      mountPoint = "/var/lib/docker";
    }
    {
      proto = "virtiofs";
      tag = "koel-music";
      source = "/data/music";
      mountPoint = "/music";
    }
    {
      proto = "virtiofs";
      tag = "koel-music-TEMP";
      source = "/var/empty";
      mountPoint = "/music/tidal-new";
    }
  ];

  secrets = {
    "vm/koel/env" = {};
  };
}
