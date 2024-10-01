{
  pkgs,
  lib,
  ...
}: {
  systemd.network.enable = true;
  networking.useDHCP = false;

  systemd.network.networks = {
    "10-wan" = {
      matchConfig.Name = "enp4s0";
      networkConfig.DHCP = "yes";
    };
  };
}
