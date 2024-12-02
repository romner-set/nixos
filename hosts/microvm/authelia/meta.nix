{...}: {
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
      tag = "authelia-data";
      source = "/vm/authelia";
      mountPoint = "/data";
    }
  ];

  users = [ "authelia" "authelia-redis" ];

  secrets = {
    "vm/authelia/db_pass" = {};
    "vm/authelia/mail_pass" = {};
    "vm/authelia/jwt_secret" = {};
    "vm/authelia/session_secret" = {};

    "vm/authelia/oidc_hmac" = {};
    "vm/authelia/oidc_jwk" = {};
  };
}
