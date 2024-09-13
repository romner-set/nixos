{
  lib,
  pkgs,
  config,
  ...
}: {
  services.davis = {
    enable = true;
    #user = "root";
    #group = "root";
    dataDir = "/data";
    adminLogin = "admin";
    adminPasswordFile = "/secrets/passwd";
    appSecretFile = "/secrets/appsecret";
    hostname = "dav.${config.networking.domain}";
    nginx = {};
    mail.dsn = "smtp://username:password@localhost:25"; #TODO
  };
}
