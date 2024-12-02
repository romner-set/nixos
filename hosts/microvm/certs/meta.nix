{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
  self = cfg.vms.certs;
  inherit (config.networking) domain;
in rec {
  id = 29;

  shares = [
    {
      proto = "virtiofs";
      tag = "certs-data";
      source = "/vm/certs";
      mountPoint = "/etc/step-ca";
    }
    {
      proto = "virtiofs";
      tag = "certs-secrets";
      source = "/run/secrets/vm/certs";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "certs-secrets-rendered";
      source = "/run/secrets/rendered/vm/certs";
      mountPoint = "/secrets/rendered";
    }
  ];

  tcpPorts = [443];

  vHosts.ca = {
    # https://smallstep.com/docs/step-ca/certificate-authority-server-production/#run-a-reverse-proxy
    locations = builtins.listToAttrs (builtins.map (path:
      lib.attrsets.nameValuePair path {
        proto = "https";
        port = 443;
      }) ["= /roots.pem" "/root/" "= /renew" "= /1.0/sign" "= /providers"]);

    bypassAuthForLAN = true;
    useInternalCA = true;
  };

  oidc.enable = true;
  oidc.redirectUris = ["http://localhost" "http://127.0.0.1"];
  oidc.authMethod = "client_secret_post";

  secrets =
    (builtins.mapAttrs (name: v: {
        format = "binary";
        sopsFile = "/secrets/${config.networking.hostName}/${name}";
      }) {
        "vm/certs/root.crt" = {};
        #"vm/certs/root.key" = {};
        "vm/certs/intermediate.crt" = {};
        "vm/certs/intermediate.key" = {};
        "vm/certs/ssh_host.key" = {};
        "vm/certs/ssh_user.key" = {};
      })
    // {
      "vm/certs/intermediate_password" = {};
      "oidc/certs/id" = {};
      "oidc/certs/secret" = {};
      "oidc/certs/secret_hash" = {};
    };

  templates."ca/chain.pem" = {
    #mode = "0444";
    content = ''
      ${config.sops.placeholder."vm/certs/root.crt"}
      ${config.sops.placeholder."vm/certs/intermediate.crt"}
    '';
  };

  templates."vm/certs/ca.json".file = (pkgs.formats.json {}).generate "ca.json" {
    root = "/secrets/root.crt";
    ca-url = "https://ca.${domain}";

    crt = "/secrets/intermediate.crt";
    key = "/secrets/intermediate.key";

    address = ":443";
    dnsNames = [
      "ca.${domain}"
      "certs.vm.${domain}"
    ];
    logger.format = "text";

    db = {
      type = "badgerv2";
      dataSource = "/etc/step-ca/db";
    };

    /*
      tls = {
      cipherSuites = [
        "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
      ];
      minVersion = "1.2";
      maxVersion = "1.3";
      renegotiation = false;
    };
    */

    ssh = {
      hostKey = "/secrets/ssh_host.key";
      userKey = "/secrets/ssh_user.key";
    };

    authority = {
      claims = {
        minTLSCertDuration = "5m";
        maxTLSCertDuration = "24h";
        defaultTLSCertDuration = "24h";
        disableRenewal = false;
        allowRenewalAfterExpiry = false;
        minHostSSHCertDuration = "5m";
        maxHostSSHCertDuration = "1680h";
        defaultHostSSHCertDuration = "720h";
        minUserSSHCertDuration = "5m";
        maxUserSSHCertDuration = "24h";
        defaultUserSSHCertDuration = "16h";
      };

      policy = {
        x509 = {
          allow.dns = [
            "${domain}"
            "*.${domain}"
            "*.vm.${domain}"
            "*.invalid" # client certs
          ];
          allowWildcardNames = true;
        };
        ssh = {
          user.allow = {
            principal = ["*"];
            email = ["@${domain}"];
          };
          host.allow.dns = ["*.${domain}" "*.vm.${domain}"];
          allowWildcardNames = false;
        };
      };

      provisioners = [
        {
          type = "OIDC";
          name = "authelia";
          admins = ["admin@${domain}"];
          domains = ["${domain}"];
          #listenAddress = ":10000";

          clientID = config.sops.placeholder."oidc/certs/id";
          clientSecret = config.sops.placeholder."oidc/certs/secret";
          configurationEndpoint = "https://auth.${domain}/.well-known/openid-configuration";

          claims = {
            maxTLSCertDuration = "8760h"; # 1 year, used for mobile devices or browsers where ACME isn't possible
            defaultTLSCertDuration = "8h";
            enableSSHCA = true;
          };
        }
        {
          type = "SSHPOP";
          name = "sshpop";
          claims.enableSSHCA = true;
        }
        {
          type = "ACME";
          name = "acme";

          forceCN = true;
          caaIdentities = [domain];
          challenges = ["dns-01"];
          attestationFormats = [
            "apple"
            "step"
            "tpm"
          ];

          claims = {
            maxTLSCertDuration = "8h";
            defaultTLSCertDuration = "2h";
          };
        }
      ];
    };
  };
}
