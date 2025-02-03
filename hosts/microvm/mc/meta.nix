{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 100;
  tcpPorts = [25565 25555];
  mem = 12288;
  vcpu = cfg.defaults.vcpu.max;

  shares = [
    {
      proto = "virtiofs";
      tag = "mc-rw-data";
      source = "/vm/mc/rw";
      mountPoint = "/rw";
    }
    {
      proto = "virtiofs";
      tag = "mc-data";
      source = "/vm/mc/data";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "mc-docker";
      source = "/vm/mc/docker";
      mountPoint = "/var/lib/docker";
    }
    {
      proto = "virtiofs";
      tag = "mc-zerotier";
      source = "/vm/mc/zerotier-one";
      mountPoint = "/var/lib/zerotier-one";
    }
    {
      proto = "virtiofs";
      tag = "mc-secrets-rendered";
      source = "/run/secrets/rendered/vm/mc";
      mountPoint = "/secrets/rendered";
    }
  ];

  secrets = {
    "vm/mc/api_key" = {};
  };

  templates."vm/mc/env".content = ''
    CF_API_KEY=${config.sops.placeholder."vm/mc/api_key"}
  '';
}
