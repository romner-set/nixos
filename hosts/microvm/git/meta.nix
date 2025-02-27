{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 14;
  webPorts = [80];
  vcpu = cfg.defaults.vcpu.max;

  vHosts.git = {
    locations."/" = {
      proto = "http";
      port = 3000;
    };
    authPolicy = "bypass";
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "git-data";
      source = "/vm/git";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "git-secrets";
      source = "/run/secrets/vm/git";
      mountPoint = "/secrets";
    }
  ];

  secrets = {
    "vm/git/mail_pass" = {};
  };
}
