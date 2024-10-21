{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 5;

  webPorts = [8080];
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.high;

  vHosts.koel = {
    locations."/" = {
      proto = "http";
      port = 8080;
    };
    authPolicy = "bypass";
    expectedMaxResponseTime = 500; # avg 256-267
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "koel-secrets";
      source = "/run/secrets-rendered/vm/koel";
      mountPoint = "/secrets/rendered";
    }
    {
      proto = "virtiofs";
      tag = "koel-data";
      source = "/vm/koel/data";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "koel-docker";
      source = "/vm/koel/docker";
      mountPoint = "/var/lib/docker";
    }
    {
      proto = "virtiofs";
      tag = "koel-music";
      source = "/data/music";
      mountPoint = "/music";
    }
    {
      proto = "virtiofs";
      tag = "koel-music-TEMP";
      source = "/var/empty";
      mountPoint = "/music/tidal-new";
    }
  ];

  secrets = {
    "vm/koel/app_key" = {};
    "vm/koel/db_password" = {};
    "vm/koel/meilisearch_key" = {};
    "vm/koel/lastfm_api_key" = {};
    "vm/koel/lastfm_api_secret" = {};
    "vm/koel/spotify_client_id" = {};
    "vm/koel/spotify_client_secret" = {};
    "vm/koel/pusher_app_id" = {};
    "vm/koel/pusher_app_key" = {};
    "vm/koel/pusher_app_secret" = {};
  };

  templates."vm/koel/env".content = ''
    APP_KEY=${config.sops.placeholder."vm/koel/app_key"}
    DB_PASSWORD=${config.sops.placeholder."vm/koel/db_password"}
    MEILISEARCH_KEY=${config.sops.placeholder."vm/koel/meilisearch_key"}
    LASTFM_API_KEY=${config.sops.placeholder."vm/koel/lastfm_api_key"}
    LASTFM_API_SECRET=${config.sops.placeholder."vm/koel/lastfm_api_secret"}
    SPOTIFY_CLIENT_ID=${config.sops.placeholder."vm/koel/spotify_client_id"}
    SPOTIFY_CLIENT_SECRET=${config.sops.placeholder."vm/koel/spotify_client_secret"}
    PUSHER_APP_ID=${config.sops.placeholder."vm/koel/pusher_app_id"}
    PUSHER_APP_KEY=${config.sops.placeholder."vm/koel/pusher_app_key"}
    PUSHER_APP_SECRET=${config.sops.placeholder."vm/koel/pusher_app_secret"}
  '';
}
