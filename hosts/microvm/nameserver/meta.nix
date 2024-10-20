{config, pkgs, ...}: let
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
      source = "/run/secrets-rendered/vm/nameserver";
      mountPoint = "/secrets/rendered";
    }
    {
      proto = "virtiofs";
      tag = "nameserver-ssl";
      source = "/vm/nginx/ssl";
      mountPoint = "/var/lib/acme";
    }
  ];

  secrets = {
    "vm/nameserver/acme/tsig_secret" = {};
    "vm/nameserver/acme/eab_kid" = {};
    "vm/nameserver/acme/eab_hmac" = {};
  };

  templates."vm/nameserver/acme.conf" = {
    mode = "0440";
    file = (pkgs.formats.yaml {}).generate "acme.conf" {
      key = {
        id = "acme";
        algorithm = "hmac-sha256";
        secret = config.sops.placeholder."vm/nameserver/acme/tsig_secret";
      };
    };
  };

  templates."vm/nameserver/acme.env".content = ''
    RFC2136_NAMESERVER=[::1]:53
    RFC2136_TSIG_ALGORITHM=hmac-sha256
    RFC2136_TSIG_KEY=acme
    RFC2136_TSIG_SECRET=${config.sops.placeholder."vm/nameserver/acme/tsig_secret"}
    LEGO_EAB=true
    LEGO_EAB_KID=${config.sops.placeholder."vm/nameserver/acme/eab_kid"}
    LEGO_EAB_HMAC=${config.sops.placeholder."vm/nameserver/acme/eab_kid"}
  '';
}
