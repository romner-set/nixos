{
  pkgs,
  lib,
  ...
}: {
  systemd.network.networks."10-wan" = {
    # Hetzner ARM VPS
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "ipv4";
    address = [
      "2a01:4f8:c010:91ac::1/64"
    ];
    routes = [
      {Gateway = "fe80::1";}
    ];
  };
  networking.hostName = "canto";
  networking.domain = "cynosure.red";
}
