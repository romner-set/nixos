{
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
in {
  id = 26;

  tcpPorts = [3478 5350];
  udpPorts = [3478 5350 8888];

  vHosts.turn = {}; # should be added to DNS but ignored otherwise

  shares = [
    {
      proto = "virtiofs";
      tag = "turn-ssl";
      source = "/vm/nginx/ssl";
      mountPoint = "/ssl";
    }
    {
      proto = "virtiofs";
      tag = "turn-secrets";
      source = "/run/secrets/vm/turn";
      mountPoint = "/secrets";
    }
  ];

  secrets = {
    "vm/turn/shared".mode = "0440";
  };
}
