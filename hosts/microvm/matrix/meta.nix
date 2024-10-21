{
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
  inherit (config.networking) domain;
in {
  id = 24;

  webPorts = [8008 8009 8448];

  vHosts."matrix-client" = {
    locations."/".port = 8008;
    authPolicy = "bypass";
    maxUploadSize = "5000M";
  };
  vHosts."matrix-slidingsync" = {
    locations."/".port = 8009;
    authPolicy = "bypass";
    maxUploadSize = "5000M";
  };
  vHosts."matrix-federation" = {
    locations."/".port = 8448;
    authPolicy = "bypass";
    maxUploadSize = "100M";
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "matrix-data";
      source = "/vm/matrix";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "matrix-secrets-rendered";
      source = "/run/secrets-rendered/vm/matrix";
      mountPoint = "/secrets/rendered";
    }
  ];

  oidc.enable = true;
  oidc.redirectUris = ["https://matrix-client.${domain}/_synapse/client/oidc/callback"];

  secrets = {
    "vm/matrix/synapse/db_pass" = {};
    "vm/matrix/sliding-sync/db_pass" = {};
    "vm/matrix/sliding-sync/secret" = {};
    "oidc/matrix/id" = {};
    "oidc/matrix/secret" = {};
    "oidc/matrix/secret_hash" = {};
  };

  templates."vm/matrix/synapse.yaml" = {
    mode = "0440";
    file = (pkgs.formats.yaml {}).generate "synapse.yaml" {
      turn_shared_secret = config.sops.placeholder."vm/turn/shared_secret";
      database = {
        name = "psycopg2";
        args.password = config.sops.placeholder."vm/matrix/synapse/db_pass";
      };
      oidc_providers = [
        {
          idp_id = "authelia";
          idp_name = "authelia";
          issuer = "https://auth.${domain}";

          client_id = config.sops.placeholder."oidc/matrix/id";
          client_secret = config.sops.placeholder."oidc/matrix/secret";

          discover = true;
          scopes = ["openid" "profile" "email"];
          user_mapping_provider.config = {
            localpart_template = "{{ user.preferred_username }}";
            display_name_template = "{{ user.preferred_username|capitalize }}"; # TODO: If your users have names in OIDC and you want those in Synapse, this should be replaced with user.name|capitalize.
          };
        }
      ];
    };
  };

  templates."vm/matrix/db-init" = {
    mode = "0440";
    content = ''
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD '${config.sops.placeholder."vm/matrix/synapse/db_pass"}';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
      CREATE ROLE "matrix-sliding-sync" WITH LOGIN PASSWORD '${config.sops.placeholder."vm/matrix/sliding-sync/db_pass"}';
      CREATE DATABASE "matrix-sliding-sync" WITH OWNER "matrix-sliding-sync"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };

  templates."vm/matrix/sliding-sync.env".content = ''
    SYNCV3_SECRET=${config.sops.placeholder."vm/matrix/sliding-sync/secret"}
    SYNCV3_DB=postgres://matrix-sliding-sync:${config.sops.placeholder."vm/matrix/sliding-sync/db_pass"}@localhost:5432/matrix-sliding-sync?sslmode=disable
  '';
}
