{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 30;

  webPorts = [1970];
  vcpu = cfg.defaults.vcpu.max;

  vHosts.swing = {
    locations."/" = {
      proto = "http";
      port = 1970;
    };
    #authPolicy = "bypass";
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
