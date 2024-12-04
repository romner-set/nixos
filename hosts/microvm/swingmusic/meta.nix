{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 30;

  webPorts = [1970];
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.high;

  vHosts.swing = {
    locations."/" = {
      proto = "http";
      port = 1970;
    };
    #authPolicy = "bypass";
    expectedMaxResponseTime = 500; # avg 256-267
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "swingmusic-data";
      source = "/vm/swingmusic";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "swingmusic-docker";
      source = "/vm/swingmusic/docker";
      mountPoint = "/var/lib/docker";
    }
    {
      proto = "virtiofs";
      tag = "swingmusic-music";
      source = "/data/music";
      mountPoint = "/music";
    }
  ];
}
