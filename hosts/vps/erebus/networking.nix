{
  pkgs,
  lib,
  ...
}: {
  systemd.network.networks."10-wan" = {
    #Oracle free-tier ARM VPS
    matchConfig.Name = "enp0s6";
    networkConfig.DHCP = "yes";
  };
  networking.hostName = "erebus";
  networking.domain = "cynosure.red";
}
