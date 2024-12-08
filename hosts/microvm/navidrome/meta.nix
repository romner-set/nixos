{
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
in {
  id = 32;

  webPorts = [4533];
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.high;

  vHosts.navidrome = {
    locations."/" = {
      proto = "http";
      port = 4533;
    };
    authPolicy = "bypass";
  };
  vHosts.music = {
    locations."/" = {
      proto = "http";
      port = 9180;
    };
    authPolicy = "bypass";
    csp = "none";
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "navidrome-music";
      source = "/data/music";
      mountPoint = "/music";
    }
    {
      proto = "virtiofs";
      tag = "navidrome-data";
      source = "/vm/navidrome";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "navidrome-secrets-rendered";
      source = "/run/secrets/rendered/vm/navidrome";
      mountPoint = "/secrets/rendered";
    }
    {
      proto = "virtiofs";
      tag = "navidrome-docker";
      source = "/vm/navidrome/docker";
      mountPoint = "/var/lib/docker";
    }
  ];

  #TODO: rework secrets once https://github.com/NixOS/nixpkgs/pull/356919 hits nixpkgs
  secrets = {
    "vm/navidrome/lastfm_api_key" = {};
    "vm/navidrome/lastfm_api_secret" = {};
    "vm/navidrome/spotify_client_id" = {};
    "vm/navidrome/spotify_client_secret" = {};
  };

  templates."vm/navidrome/config.json".file = (pkgs.formats.json {}).generate "config.json" {
    Address = "[::]";

    MusicFolder = "/music";
    DataFolder = "/data/data";
    CacheFolder = "/data/cache";

    EnableSharing = true;
    EnableUserEditing = false;
    DefaultTheme = "Catppuccin Macchiato";

    RecentlyAddedByModTime = true;
    ScanSchedule = "0"; # manual scans only

    LastFM = {
      ApiKey = config.sops.placeholder."vm/navidrome/lastfm_api_key";
      Secret = config.sops.placeholder."vm/navidrome/lastfm_api_secret";
    };
    Spotify = {
      ID = config.sops.placeholder."vm/navidrome/spotify_client_id";
      Secret = config.sops.placeholder."vm/navidrome/spotify_client_secret";
    };
  };
}
