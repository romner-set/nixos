{
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.server.microvm;
in {
  id = 25;

  webPorts = [80];

  locations."/" = {
    proto = "http";
    port = 80;
  };
  authPolicy = "bypass";
  #TODO: expectedMaxResponseTime = x; # avg y-z

  maxUploadSize = "5000M";
}
