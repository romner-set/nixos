{
  config,
  pkgs,
  ...
}: let
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
      source = "/run/secrets/rendered/vm/nameserver";
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
  };

  templates."vm/nameserver/acme.conf" = {
    #mode = "0440";
    # I'd use (pkgs.formats.yaml {}).generate but knot is whitespace-sensitive for some reason...
    content = ''
      key:
        - id: acme
          algorithm: hmac-sha256
          secret: ${config.sops.placeholder."vm/nameserver/acme/tsig_secret"}
    '';
  };
}
