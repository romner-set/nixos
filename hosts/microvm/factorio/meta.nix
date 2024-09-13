cfg: {
  id = 101;
  udpPorts = [34197];
  mem = cfg.defaults.mem.high;
  vcpu = cfg.defaults.vcpu.max;

  shares = [
    {
      proto = "virtiofs";
      tag = "factorio-data";
      source = "/vm/factorio/data";
      mountPoint = "/var/lib/factorio/saves";
    }
    {
      proto = "virtiofs";
      tag = "factorio-zerotier";
      source = "/vm/factorio/zerotier-one";
      mountPoint = "/var/lib/zerotier-one";
    }
  ];
}
