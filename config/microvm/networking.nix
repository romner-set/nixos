{
  config,
  configLib,
  lib,
  ...
}:
with lib; let
  cfg = config.cfg.microvm.net;
  self = vms.${config.networking.hostName};

  mac = configLib.decToHex self.id "";
  fullMAC = "02:00:00:00:01:${
    if stringLength mac == 1
    then "0"
    else ""
  }${mac}";

  inherit (config.cfg.microvm.host) vms net;
  inherit (net) ipv4 ipv6;
in {
  options.cfg.microvm.net = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    systemd.network = {
      enable = true;

      networks = {
        "40-wan" = {
          matchConfig.PermanentMACAddress = fullMAC;
          #matchConfig.Type = "ether";
          networkConfig.LinkLocalAddressing = "no";
          addresses = [
            {addressConfig = {Address = "${ipv4.subnet.microvm}.${toString self.id}/32";};}
            {addressConfig = {Address = "${ipv6.subnet.microvm}::${toString self.id}/128";};}
            {addressConfig = {Address = "${ipv6.subnet.microvmPublic}::${toString self.id}/128";};}
          ];
          routes = [
            {
              # fe80::1 is only used to discover MAC addr, so it works for IPv4 as well (magic)
              routeConfig.Gateway = "fe80::1";
              routeConfig.Source = "${ipv4.subnet.microvm}.${toString self.id}";
            }
            {routeConfig.Gateway = "fe80::1";}
          ];
          linkConfig.RequiredForOnline = "routable";
        };
      };
    };

    networking = {
      useDHCP = false;

      nftables.enable = true;
      firewall = {
        enable = false;
        filterForward = true;
        allowedTCPPorts = self.tcpPorts;
        allowedUDPPorts = self.udpPorts;
        extraInputRules = lib.strings.concatStrings [
          (lib.strings.concatMapStrings (
              port: "ip6 saddr { ${ipv6.subnet.microvm}::${toString vms.nginx.id}/128 } tcp dport ${toString port} accept\n"
            )
            self.webPorts)
          (lib.strings.concatMapStrings (
              port: "ip6 saddr { ${ipv6.subnet.microvm}::${toString vms.nginx.id}/128 } udp dport ${toString port} accept\n"
            )
            self.webPortsUDP)
        ];
      };
    };
  };
}
