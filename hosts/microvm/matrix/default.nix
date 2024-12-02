{
  lib,
  pkgs,
  config,
  configLib,
  unstable,
  domain,
  ...
}:
with lib; let
  inherit (config.networking) domain;
in {
  services.postgresql = {
    enable = true;
    dataDir = "/data/db";

    package = pkgs.postgresql_15;

    initialScript = "/run/certificates/postgresql.service/rendered-db-init";
  };

  ## SYNAPSE

  systemd.services.postgresql.serviceConfig.LoadCredential = configLib.toCredential ["rendered/db-init"];
  systemd.services.matrix-synapse.serviceConfig.LoadCredential = configLib.toCredential ["rendered/synapse.yaml"];

  services.matrix-synapse = {
    enable = true;
    dataDir = "/data/synapse";

    configureRedisLocally = true;
    settings = {
      server_name = domain;
      public_baseurl = "https://matrix-client.${domain}/";

      max_upload_size = "5G";

      allow_public_rooms_without_auth = false;
      allow_public_rooms_over_federation = false;

      turn_uris = [
        "turns:turn.${domain}:5349?transport=udp"
        "turns:turn.${domain}:5349?transport=tcp"
        "turn:turn.${domain}:3478?transport=udp"
        "turn:turn.${domain}:3478?transport=tcp"
      ];
      turn_user_lifetime = "1h";

      listeners = [
        {
          port = 8008;
          bind_addresses = ["::"];
          resources = [
            {
              compress = true;
              names = ["client"];
            }
          ];
          tls = false;
          type = "http";
          x_forwarded = true;
        }
        {
          port = 8448;
          bind_addresses = ["::"];
          resources = [
            {
              compress = false;
              names = ["federation"];
            }
          ];
          tls = false;
          type = "http";
          x_forwarded = true;
        }
      ];
    };

    extras = ["oidc"];
    extraConfigFiles = ["/run/credentials/matrix-synapse.service/rendered-synapse.yaml"]; #defined in meta.ni
  };

  /*
    systemd.services.matrix-authentication-service = {
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${unstable.matrix-authentication-service}/bin/matrix-authentication-service";
      Restart = "on-failure";
      RestartSec = 10;
      StartLimitBurst = 5;
    };
  };
  */

  #environment.systemPackages = [ unstable.matrix-authentication-service ];
}
