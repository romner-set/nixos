{
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
in {
  id = 23;

  webPorts = [80];
  vcpu = cfg.defaults.vcpu.max;
  mem = cfg.defaults.mem.high;

  vHosts.meelo = {
    locations."/" = {
      proto = "http";
      port = 80;
    };
    #authPolicy = "bypass";
    expectedMaxResponseTime = 50; # avg 13-19
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "meelo-data";
      source = "/vm/meelo/data";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "meelo-config";
      source = "/vm/meelo/config";
      mountPoint = "/etc/meelo";
    }
    {
      proto = "virtiofs";
      tag = "meelo-docker";
      source = "/vm/meelo/docker";
      mountPoint = "/var/lib/docker";
    }
    {
      proto = "virtiofs";
      tag = "meelo-music";
      source = "/data/music";
      mountPoint = "/music";
    }
    {
      proto = "virtiofs";
      tag = "meelo-secrets";
      source = "/run/secrets-rendered/vm/meelo";
      mountPoint = "/secrets/rendered";
    }
  ];

  secrets = {
    "vm/meelo/db_pass" = {};
    "vm/meelo/jwt_secret" = {};
    "vm/meelo/meili" = {};
    "vm/meelo/discogs_apikey" = {};
    "vm/meelo/genius_apikey" = {};
  };

  templates."vm/meelo/env".content = ''
    #################### Database
    # The port on the host where meelo will be accessible
    PORT=80
    # Username to access database
    POSTGRES_USER=meelo
    # Password to access database
    POSTGRES_PASSWORD=${config.sops.placeholder."vm/meelo/db_pass"}
    # Name of Meelo's database
    POSTGRES_DB=meelo
    #################### Config
    # The directory that contains the `settings.json` file (and where the illustrations will be stored) (on the host machine)
    CONFIG_DIR=/etc/meelo
    # The root path of your libraries (on the host machine)
    DATA_DIR=/data
    #################### Anonymous Access
    # Set to 1 if you want to allow anonymous request
    # This will not affect front-end behaviour
    ALLOW_ANONYMOUS=0
    #################### Web app
    # URL of the server/api that would be accessible to the front app's server or any client
    # If PORT=5000, it should look like 'http://0.0.0.0:5000/api' (mind the '/api')
    # Used for healthcheck
    PUBLIC_SERVER_URL=https://meelo.${config.networking.domain}/api
    #################### Security
    # Random String used to sign JWT Tokens
    JWT_SIGNATURE=${config.sops.placeholder."vm/meelo/jwt_secret"}
    # Key used to authenticate the Meilisearch Instance
    # Should be a random string, must be at least 16 bytes
    MEILI_MASTER_KEY=${config.sops.placeholder."vm/meelo/meili"}
    #################### Internal
    # Do not change this
    INTERNAL_DATA_DIR=/data
    INTERNAL_CONFIG_DIR=/config
  '';

  templates."vm/meelo/settings.json".file = (pkgs.formats.json {}).generate "settings.json" {
    trackRegex = [
      "^(.+\\/)*(?<Artist>[^\\/]+)\\/(?<Album>[^\\/]+) \\[(?<Year>\\d+)\\]( \\[[^\\/]+\\])*\\/(CD (?<Disc>\\d+)*\\/)*(?<Index>\\d+) - (?<AlbumArtist>[^\\/]+) - (?<Title>[^\\/]+)\\..+$"
    ];
    metadata = {
      source = "path"; # prefer cover.jpg instead of using track cover as album cover
      order = "preferred";
      useExternalProviderGenres = true;
    };
    providers = {
      musicbrainz.enable = true;
      wikipedia.enable = true;
      metacritic.enable = true;
      genius = {
        enable = true;
        apiKey = config.sops.placeholder."vm/meelo/genius_apikey";
      };
      discogs = {
        enable = true;
        apiKey = config.sops.placeholder."vm/meelo/discogs_apikey";
      };
    };
    compilations = {
      useID3CompTag = false;
      artists = [
        "Various Artists"
      ];
    };
  };
}
