cfg: {
  id = 1;
  vcpu = cfg.defaults.vcpu.max;

  tcpPorts = [80 443];
  udpPorts = [443];

  shares = [
    {
      proto = "virtiofs";
      tag = "nginx-secrets";
      source = "/run/secrets/vm/nginx";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "ssl";
      source = "/vm/nginx/ssl";
      mountPoint = "/ssl";
    }
    {
      proto = "virtiofs";
      tag = "srv";
      source = "/vm/nginx/srv";
      mountPoint = "/srv";
    }
  ];

  secrets = {
    "vm/nginx/rathole-1.toml" = {};
    "vm/nginx/rathole-2.toml" = {};
  };
}
