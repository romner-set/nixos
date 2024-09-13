{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  #TODO: inherit (config.cfg.microvm.host.vms.${config.networking.hostName}.config) syncthing;
in {
  config = {
    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 204800;
    };
    services.syncthing = {
      enable = true;
      user = "root";
      group = "root";
      key = "/secrets/key.pem";
      cert = "/secrets/cert.pem";
      guiAddress = "[::]:8080";
      #dataDir = "/sync";
      #configDir = "/var/lib/syncthing";
      settings = {
        options = {
          globalAnnounceEnabled = false;
          natEnabled = false;
          urAccepted = 3;
          relaysEnabled = false;
          localAnnounceEnabled = false;
        };
        /*
        devices = syncthing.devices;
        folders =
          builtins.mapAttrs (dir: devs: {
            path = "/sync/${dir}";
            devices = devs;
          })
          syncthing.dirs;
        */
      };
    };
  };
}
