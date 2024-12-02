{config, ...}: let
  inherit (config.networking) domain;
in {
  # MANUAL SETUP NECESSARY: https://www.authelia.com/integration/openid-connect/immich/#application
  id = 16;

  webPorts = [2283];

  vHosts.immich = {
    locations."/" = {
      proto = "http";
      port = 2283;
    };
    #authPolicy = "bypass";
    bypassAuthForLAN = true;
    requireMTLS = true;

    maxUploadSize = "50000M";
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "immich-secrets";
      source = "/run/secrets/rendered/vm/immich";
      mountPoint = "/secrets/rendered";
    }
    {
      proto = "virtiofs";
      tag = "immich-data";
      source = "/vm/immich/data";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "immich-docker";
      source = "/vm/immich/docker";
      mountPoint = "/var/lib/docker";
    }
  ];

  oidc.enable = true;
  oidc.redirectUris = [
    "app.immich:///oauth-callback" # mobile app
    "https://immich.${domain}/auth/login"
    "https://immich.${domain}/user-settings"
  ];

  secrets = {
    "vm/immich/db_pass" = {};
    "oidc/immich/id" = {};
    "oidc/immich/secret" = {};
    "oidc/immich/secret_hash" = {};
  };

  templates."vm/immich/env".content = ''
    # You can find documentation for all the supported env variables at https://immich.app/docs/install/environment-variables

    # The location where your uploaded files are stored
    UPLOAD_LOCATION=/data/library
    # The location where your database files are stored
    DB_DATA_LOCATION=/data/postgres

    TZ=Europe/Prague
    IMMICH_VERSION=release
    DB_PASSWORD=${config.sops.placeholder."vm/immich/db_pass"}

    # The values below this line do not need to be changed
    ###################################################################################
    DB_USERNAME=postgres
    DB_DATABASE_NAME=immich
  '';
}
