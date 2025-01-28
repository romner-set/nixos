{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 35;

  webPorts = [8083 8084];

  vHosts.lib = {
    locations."/" = {
      proto = "http";
      port = 8083;
    };
    authPolicy = "bypass";
  };

  vHosts.libdl = {
    locations."/" = {
      proto = "http";
      port = 8084;
    };
    csp = "none"; # CDN javascript...
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "calibre-data";
      source = "/vm/calibre";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "calibre-books";
      source = "/data/media/calibre";
      mountPoint = "/library";
    }
    {
      proto = "virtiofs";
      tag = "calibre-docker";
      source = "/vm/calibre/docker";
      mountPoint = "/var/lib/docker";
    }
  ];
}
