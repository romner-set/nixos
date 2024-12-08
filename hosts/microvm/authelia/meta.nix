{config, pkgs, ...}: {
  id = 2;

  webPorts = [9091];

  vHosts.auth.locations."/" = {
    proto = "http";
    port = 9091;
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "authelia-secrets-oidc";
      source = "/run/secrets/oidc";
      mountPoint = "/secrets/oidc";
    }
    {
      proto = "virtiofs";
      tag = "authelia-secrets";
      #securityModel = "mapped-file";
      source = "/run/secrets/vm/authelia";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "authelia-secrets-rendered";
      source = "/run/secrets/rendered/vm/authelia";
      mountPoint = "/secrets/rendered";
    }
    {
      proto = "virtiofs";
      tag = "authelia-data";
      source = "/vm/authelia";
      mountPoint = "/data";
    }
  ];

  users = [ "authelia" "authelia-redis" ];

  secrets = {
    "vm/authelia/admin_pass" = {};

    "vm/authelia/db_pass" = {};
    "vm/authelia/mail_pass" = {};
    "vm/authelia/jwt_secret" = {};
    "vm/authelia/session_secret" = {};

    "vm/authelia/oidc_hmac" = {};
    "vm/authelia/oidc_jwk" = {};
  };

  templates."vm/authelia/users.yml".file = (pkgs.formats.yaml {}).generate "users.yml" {
    users.admin = {
      disabled = false;
      displayname = "admin";
      password = config.sops.placeholder."vm/authelia/admin_pass";
      email = "admin@${config.networking.domain}";
      groups = [ "admin" ];
    };
  };
}
