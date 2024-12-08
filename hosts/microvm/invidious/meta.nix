{
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
in {
  id = 31;

  webPorts = [80];
  vcpu = cfg.defaults.vcpu.max;

  vHosts.invidious = {
    locations."/" = {
      proto = "http";
      port = 80;
    };
    bypassAuthForLAN = true;
    csp = "none";
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "invidious-data";
      source = "/vm/invidious";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "invidious-secrets-rendered";
      source = "/run/secrets/rendered/vm/invidious";
      mountPoint = "/secrets/rendered";
    }
  ];

  secrets = {
    "vm/invidious/po_token" = {};
    "vm/invidious/visitor_data" = {};
  };

  templates."vm/invidious/session.json".file = (pkgs.formats.json {}).generate "session.json" {
    po_token = config.sops.placeholder."vm/invidious/po_token";
    visitor_data = config.sops.placeholder."vm/invidious/visitor_data";
  };
}
