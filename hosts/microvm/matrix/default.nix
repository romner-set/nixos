{
  config,
  lib,
  pkgs,
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

    initialScript = "/secrets/rendered/db-init";
  };

  ## SYNAPSE

  systemd.services.postgresql.serviceConfig = {
    # allow reading necessary secrets with chmod 440
    Group = mkForce "root";
  };
  systemd.services.matrix-synapse.serviceConfig = {
    # allow reading necessary secrets with chmod 440
    Group = mkForce "root";
  };

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
        "turns:turn.${domain}?transport=udp"
	"turns:turn.${domain}?transport=tcp"
        "turn:turn.${domain}?transport=udp"
	"turn:turn.${domain}?transport=tcp"
      ];
      turn_shared_secret_file = "/secrets/turn/shared";
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
    extraConfigFiles = ["/secrets/rendered/synapse.yaml"]; #defined in meta.ni
  };

  ## SLIDING SYNC

  services.matrix-sliding-sync = {
    enable = true;
    environmentFile = "/secrets/rendered/sliding-sync.env";
    settings = {
      SYNCV3_BINDADDR = "[::]:8009";
      SYNCV3_SERVER = "http://[::1]:8008";
    };
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
