{
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
in {
  id = 33;

  webPorts = [5030];
  tcpPorts = [50300];
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.high;

  vHosts.slskd = {
    locations."/" = {
      proto = "http";
      port = 5030;
    };
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "slskd-music";
      source = "/data/music";
      mountPoint = "/music";
    }
    {
      proto = "virtiofs";
      tag = "slskd-data";
      source = "/vm/slskd";
      mountPoint = "/var/lib/slskd";
    }
    {
      proto = "virtiofs";
      tag = "slskd-secrets-rendered";
      source = "/run/secrets/rendered/vm/slskd";
      mountPoint = "/secrets/rendered";
    }
  ];

  secrets = {
    "vm/slskd/username" = {};
    "vm/slskd/password" = {};
    "vm/slskd/description" = {};
  };

  templates."vm/slskd/env".content = ''
    SLSKD_SLSK_USERNAME=${config.sops.placeholder."vm/slskd/username"}
    SLSKD_SLSK_PASSWORD=${config.sops.placeholder."vm/slskd/password"}
    SLSKD_SLSK_DESCRIPTION=${config.sops.placeholder."vm/slskd/description"}
    SLSKD_PASSWORD=${config.sops.placeholder."vm/slskd/password"}
  '';
}
