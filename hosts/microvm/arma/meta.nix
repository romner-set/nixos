{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 103;
  udpPorts = [2302 9987];
  tcpPorts = [2302 30033];
  mem = 10240;
  vcpu = cfg.defaults.vcpu.max;

  shares = [
    {
      proto = "virtiofs";
      tag = "arma-data";
      source = "/vm/arma/data";
      mountPoint = "/arma3";
    }
    {
      proto = "virtiofs";
      tag = "arma-ts3-data";
      source = "/vm/arma/ts3";
      mountPoint = "/ts3";
    }
    {
      proto = "virtiofs";
      tag = "arma-docker";
      source = "/vm/arma/docker";
      mountPoint = "/var/lib/docker";
    }
    {
      proto = "virtiofs";
      tag = "arma-secrets-rendered";
      source = "/run/secrets/rendered/vm/arma";
      mountPoint = "/secrets/rendered";
    }
  ];

  secrets = {
    "vm/arma/steam_user" = {};
    "vm/arma/steam_pass" = {};
  };

  templates."vm/arma/env".content = ''
    ARMA_BINARY=./arma3server_x64
    ARMA_CDLC=csla;gm;vn;ws;spe
    ARMA_CONFIG=main.cfg
    ARMA_LIMITFPS=240
    ARMA_PARAMS=-autoInit
    ARMA_PROFILE=main
    ARMA_WORLD=vt7
    HEADLESS_CLIENTS=0
    HEADLESS_CLIENTS_PROFILE="$profile-hc-$i" # valid placeholders: $profile, $i, $ii
    MODS_LOCAL=true
    MODS_PRESET=/arma3/mods.html
    PORT=2302
    STEAM_BRANCH=public
    STEAM_BRANCH_PASSWORD=
    STEAM_USER=${config.sops.placeholder."vm/arma/steam_user"}
    STEAM_PASSWORD=${config.sops.placeholder."vm/arma/steam_pass"}
  '';
}
