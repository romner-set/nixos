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
      source = "/run/secrets/rendered/vm/git-runner";
      mountPoint = "/secrets/rendered";
    }
    {
      proto = "virtiofs";
      tag = "git-runner-docker";
      source = "/vm/git-runner/docker";
      mountPoint = "/var/lib/docker";
    }
  ];

  secrets = {
    "vm/git-runner/token" = {};
  };

  templates."vm/git-runner/env".content = ''
    TOKEN=${config.sops.placeholder."vm/git-runner/token"}
  '';
}
