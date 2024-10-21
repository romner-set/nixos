{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 102;
  webPorts = [30000];
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.high;

  vHosts.foundryvtt = {
    locations."/" = {
      proto = "http";
      port = 30000;
    };
    csp = "none";
    authPolicy = "bypass";
  };

  shares = [
    /*
      {
      proto = "virtiofs";
      tag = "foundryvtt-docker";
      source = "/vm/foundryvtt/docker";
      mountPoint = "/var/lib/docker";
    }
    */
    {
      proto = "virtiofs";
      tag = "foundryvtt-secrets";
      source = "/run/secrets/vm/foundryvtt";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "foundryvtt-data";
      source = "/vm/foundryvtt";
      mountPoint = "/data";
    }
  ];

  secrets = {
    "vm/foundryvtt/user" = {};
    "vm/foundryvtt/pass" = {};
    "vm/foundryvtt/admin_key" = {};
  };

  templates."vm/foundryvtt/env".content = ''
    FOUNDRY_USERNAME=${config.sops.placeholder."vm/foundryvtt/user"}
    FOUNDRY_PASSWORD=${config.sops.placeholder."vm/foundryvtt/pass"}
    FOUNDRY_ADMIN_KEY=${config.sops.placeholder."vm/foundryvtt/admin_key"}
  '';
}
