{
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
in {
  id = 36;

  webPorts = [8001];

  vHosts.archiveteam = {
    locations."/" = {
      proto = "http";
      port = 8001;
    };
    #authPolicy = "bypass";
    #expectedMaxResponseTime = 50;
  };

  shares = [
    /*
      {
      proto = "virtiofs";
      tag = "archiveteam-data";
      source = "/vm/archiveteam/data";
      mountPoint = "/data";
    }
    */
    {
      proto = "virtiofs";
      tag = "archiveteam-archive";
      source = "/archive/archiveteam";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "archiveteam-docker";
      source = "/vm/archiveteam/docker";
      mountPoint = "/var/lib/docker";
    }
  ];
}
