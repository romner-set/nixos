{
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
in {
  id = 25;

  webPorts = [80];

  vHosts.element = {
    locations."/" = {
      proto = "http";
      port = 80;
    };
    authPolicy = "bypass";
    maxUploadSize = "5000M";
    csp = "none";
  };
}
