{
  lib,
  pkgs,
  ...
}: {
  services.tor = {
    enable = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings.BandWidthRate = "50 MBytes"; #TODO
  };
}
