cfg: {
  id = 2;

  webPorts = [9091];

  subdomain = "auth";
  locations."/" = {
    proto = "http";
    port = 9091;
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "authelia-secrets";
      #securityModel = "mapped-file";
      source = "/run/secrets/vm/authelia";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "authelia";
      source = "/vm/authelia";
      mountPoint = "/data";
    }
  ];

  secrets = {
    "vm/authelia/db_pass" = {};
    "vm/authelia/mail_pass" = {};
    "vm/authelia/jwt_secret" = {};
  };
}
