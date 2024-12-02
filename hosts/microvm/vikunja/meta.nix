{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain;
in {
  id = 20;

  webPorts = [3456];

  vHosts.vikunja = {
    locations."/" = {
      proto = "http";
      port = 3456;
    };
    bypassAuthForLAN = true;
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "vikunja-data";
      source = "/vm/vikunja";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "vikunja-secrets-rendered";
      source = "/run/secrets/rendered/vm/vikunja";
      mountPoint = "/secrets/rendered";
    }
  ];

  oidc.enable = true;
  oidc.redirectUris = ["https://vikunja.${domain}/auth/openid/authelia"];

  secrets = {
    "vm/vikunja/mail_pass" = {};
    "oidc/vikunja/id" = {};
    "oidc/vikunja/secret" = {};
    "oidc/vikunja/secret_hash" = {};
  };

  templates."vm/vikunja/env".content = ''
    VIKUNJA_MAILER_PASSWORD=${config.sops.placeholder."vm/vikunja/mail_pass"}
  '';

  templates."vm/vikunja/config.yaml".file = (pkgs.formats.yaml {}).generate "config.yaml" {
    database.path = "/data/vikunja.db";

    service = {
      enableregistration = false;
      publicurl = "https://vikunja.${domain}";
    };

    timezone = config.time.timeZone;
    enableuserdeletion = false;

    mailer = {
      enabled = true;
      host = "mail.${domain}";
      port = 465;
      username = "vikunja@${domain}";
      # password set in VIKUNJA_MAILER_PASSWORD env
      fromemail = "vikunja@${domain}";
      forcessl = true;
    };

    files = {
      basepath = lib.mkForce "/data/files";
      maxsize = "100MB";
    };

    auth.local.enabled = false;

    auth.openid = {
      enabled = true;
      redirecturl = "https://vikunja.${domain}/auth/openid/";
      providers = [
        {
          name = "Authelia";
          authurl = "https://auth.${domain}";
          clientid = config.sops.placeholder."oidc/vikunja/id";
          clientsecret = config.sops.placeholder."oidc/vikunja/secret";
          scope = "openid profile email";
        }
      ];
    };
  };
}
