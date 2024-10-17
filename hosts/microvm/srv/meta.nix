{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 27;
  vcpu = cfg.defaults.vcpu.low;
  mem = cfg.defaults.mem.low;

  webPorts = [80 81];

  vHosts.srv = {
    locations."/" = {
      proto = "http";
      port = 80;
    };
    authPolicy = "bypass";
    csp = "strict";
  };

  # srv private
  vHosts.srvp = {
    locations."/" = {
      proto = "http";
      port = 81;
    };
    authPolicy = "two_factor";
    csp = "strict";
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "srv-public";
      source = "/srv/public";
      mountPoint = "/srv/public";
    }
    {
      proto = "virtiofs";
      tag = "srv-private";
      source = "/srv/private";
      mountPoint = "/srv/private";
    }
  ];
}
