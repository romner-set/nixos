{
  config,
  configLib,
  lib,
  hostNetwork,
  vms,
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

  inherit (hostNetwork) ipv4 ipv6;
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
          networkConfig.LinkLocalAddressing = "no";
          addresses = [
            {
              addressConfig = {
                Address = "${ipv4.subnet.microvm}.${toString self.id}/32";
                Peer = "${ipv4.subnet.microvmHost}.${toString self.id}/32";
              };
            }
            {
              addressConfig = {
                Address = "${ipv6.subnet.microvm}::${toString self.id}/128";
                Peer = "${ipv6.subnet.microvmHost}::${toString self.id}/128";
              };
            }
          ];
          routes = [
            {routeConfig.Gateway = "${ipv4.subnet.microvmHost}.${toString self.id}";}
            {routeConfig.Gateway = "${ipv6.subnet.microvmHost}::${toString self.id}";}
          ];
          linkConfig.RequiredForOnline = "routable";
          extraConfig = let
            fullHostMAC = "02:00:00:00:00:${
              if stringLength mac == 1
              then "0"
              else ""
            }${mac}";
          in ''
            [Neighbor]
            Address=${ipv4.subnet.microvmHost}.${toString self.id}
            LinkLayerAddress=${fullHostMAC}

            [Neighbor]
            Address=${ipv6.subnet.microvmHost}::${toString self.id}
            LinkLayerAddress=${fullHostMAC}
          '';
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
