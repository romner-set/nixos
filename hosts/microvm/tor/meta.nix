{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 10;
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.low;

  tcpPorts = [9001];

  shares = [
    {
      proto = "virtiofs";
      tag = "tor-keys";
      source = "/vm/tor";
      mountPoint = "/var/lib/tor";
    }
  ];
}
