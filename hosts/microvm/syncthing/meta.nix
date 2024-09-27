{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 4;
  tcpPorts = [8080];
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.high;

  locations."/" = {
    proto = "http";
    port = 8080;
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "syncthing-secrets";
      source = "/run/secrets/vm/syncthing";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "syncthing";
      source = "/vm/syncthing";
      mountPoint = "/var/lib/syncthing/.config/syncthing";
    }
    {
      proto = "virtiofs";
      tag = "sync";
      source = "/sync";
      mountPoint = "/sync";
    }
  ];

  secrets = {
    "vm/syncthing/cert.pem" = {};
    "vm/syncthing/key.pem" = {};
  };
}
