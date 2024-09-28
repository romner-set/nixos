{config, ...}: let
  inherit (config.networking) domain;
in {
  # MANUAL SETUP NECESSARY: https://www.authelia.com/integration/openid-connect/immich/#application
  id = 16;

  webPorts = [2283];
  locations."/" = {
    proto = "http";
    port = 2283;
  };
  #authPolicy = "bypass";
  bypassAuthForLAN = true;

  maxUploadSize = "50000M";

  shares = [
    {
      proto = "virtiofs";
      tag = "immich-secrets";
      source = "/run/secrets/vm/immich";
      mountPoint = "/secrets";
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
    "app.immich:/" # mobile app
    "https://immich.${domain}/auth/login"
    "https://immich.${domain}/user-settings"
  ];

  secrets = {
    "vm/immich/env" = {};
    "oidc/immich/id" = {};
    "oidc/immich/secret" = {};
    "oidc/immich/secret_hash" = {};
  };
}
