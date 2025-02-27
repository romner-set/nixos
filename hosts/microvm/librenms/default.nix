{
  lib,
  pkgs,
  ...
}:
with lib; {
  services.librenms = {
    enable = true;

    dataDir = "/data/data";
    logDir = "/data/log";

    environmentFile = "/secrets/rendered/env";

    database.createLocally = true;
    database.passwordFile = "/secrets/dbpassword";
  };
}
