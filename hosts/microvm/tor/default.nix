{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.networking) domain;
in {
  services.tor = {
    enable = true;
    enableGeoIP = false;

    relay = {
      enable = true;
      role = "relay";
    };

    settings = {
      Nickname = "5f2690a2c0d0ddbb";
      ContactInfo = "admin@${domain}";

      MaxAdvertisedBandwidth = "250 MB";
      BandWidthRate = "100 MB";
      RelayBandwidthRate = "100 MB";
      RelayBandwidthBurst = "250 MB";

      ExitRelay = false;
      SocksPort = 0;

      AvoidDiskWrites = 1;
      HardwareAccel = 1;
      SafeLogging = 1;
      NumCPUs = 4;

      ORPort = [9001];
    };
  };
}
