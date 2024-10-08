{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 9;

  udpPorts = [53 853];
  tcpPorts = [53];
  vcpu = cfg.defaults.vcpu.max;

  shares = [
    {
      proto = "virtiofs";
      tag = "nameserver-data";
      source = "/vm/nameserver";
      mountPoint = "/var/lib/knot";
    }
    {
      proto = "virtiofs";
      tag = "nameserver-secrets";
      source = "/run/secrets/vm/nameserver";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "nameserver-ssl";
      source = "/vm/nginx/ssl";
      mountPoint = "/var/lib/acme";
    }
  ];

  secrets = {
    "vm/nameserver/acme.env" = {};
    "vm/nameserver/acme.conf" = {};
  };
}
