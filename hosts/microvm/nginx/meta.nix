{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 1;
  vcpu = cfg.defaults.vcpu.max;

  tcpPorts = [80 443];
  udpPorts = [443];

  shares = [
    {
      proto = "virtiofs";
      tag = "nginx-secrets-rendered";
      source = "/run/secrets-rendered/vm/nginx";
      mountPoint = "/secrets/rendered";
    }
    {
      proto = "virtiofs";
      tag = "nginx-ssl";
      source = "/vm/nginx/ssl";
      mountPoint = "/ssl";
    }
    {
      proto = "virtiofs";
      tag = "nginx-ssl-acme";
      source = "/vm/nginx/ssl";
      mountPoint = "/var/lib/acme";
    }
  ];

  secrets = {
    "vm/nginx/acme/eab_kid" = {};
    "vm/nginx/acme/eab_hmac" = {};
  };

  templates = let
    common = ''
      RFC2136_NAMESERVER=[${config.cfg.server.net.ipv6.subnet.microvm}::${toString cfg.vms.nameserver.id}]:53
      RFC2136_TSIG_ALGORITHM=hmac-sha256
      RFC2136_TSIG_KEY=acme
      RFC2136_TSIG_SECRET=${config.sops.placeholder."vm/nameserver/acme/tsig_secret"}
    '';
  in {
    "vm/nginx/acme.env".content =
      common
      + ''
        LEGO_EAB=true
        LEGO_EAB_KID=${config.sops.placeholder."vm/nginx/acme/eab_kid"}
        LEGO_EAB_HMAC=${config.sops.placeholder."vm/nginx/acme/eab_hmac"}
      '';

    "vm/nginx/acme-internal.env".content = common;
  };
}
