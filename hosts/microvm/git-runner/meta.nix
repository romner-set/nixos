{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 15;
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.high;

  shares = [
    {
      proto = "virtiofs";
      tag = "git-runner-secrets";
      source = "/run/secrets/vm/git-runner";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "git-runner-docker";
      source = "/vm/git-runner/docker";
      mountPoint = "/var/lib/docker";
    }
  ];

  secrets = {
    "vm/git-runner/env" = {};
  };
}
