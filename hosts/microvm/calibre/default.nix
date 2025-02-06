{
  config,
  configLib,
  lib,
  pkgs,
  ...
}: {
  /*
    services.calibre-server = {
    enable = true;
    user = "vm-calibre";
    group = "vm-calibre";
    libraries = [ "/library" ];
    extraFlags = [
      "--disable-local-write"
      "--disable-log-not-found"
      "--disable-use-bonjour"
    ];
  };
  */

  /*
    services.calibre-web = {
    enable = true;
    user = "vm-calibre";
    group = "vm-calibre";
    listen.ip = "::";
    listen.port = 8083;
    options = {
      calibreLibrary = "/library";
      enableBookUploading = true;
      enableBookConversion = true;
    };
  };
  */

  svc.watchtower.enable = true;
  svc.docker.${config.networking.hostName} = {
    enable = true;
    compose = ./docker-compose.yml;
  };
}
