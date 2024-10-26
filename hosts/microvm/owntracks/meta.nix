{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 28;

  webPorts = [8083 80];

  vHosts.owntracks = {
    locations."/" = {
      proto = "http";
      port = 8083;
    };
    bypassAuthForLAN = true;
    requireMTLS = true;
    csp = "none";
  };
  vHosts.owntracks-fe = {
    locations."/" = {
      proto = "http";
      port = 80;
    };
    csp = "none";
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "owntracks-data";
      source = "/vm/owntracks/data";
      mountPoint = "/data";
    }
  ];
}
