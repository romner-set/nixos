{
  config,
  configLib,
  lib,
  unstable,
  ...
}:
with lib;
with lib.strings; let
  cfg = config.cfg.server.net;
  inherit (cfg) ipv4 ipv6;
in {
  imports = configLib.scanPath ./.;

  options.cfg.server.net = {
    enable = mkEnableOption "";
    systemd.enable = mkOption {
      type = types.bool;
      default = true;
    };

    vlans = mkOption {
      type = with types;
        attrsOf (submodule ({name, ...}: {
          options = {
            enable = mkEnableOption "";
            name = mkOption {
              type = types.str;
              default = name;
            };
            id = mkOption {type = types.int;};
          };
        }));
      default = {};
    };

    interface = mkOption {
      type = types.str;
      default = "eth0";
    };

    ipv4 = {
      publicAddress = mkOption {type = types.str;}; # external addr
      address = mkOption {type = types.str;};
      subnetSize = mkOption {type = types.ints.u8;};
      gateway = mkOption {type = types.str;};

      subnet = {
        microvmHost = mkOption {
          type = types.str;
          default = "172.30.0"; # doesn't include host /24 part
        };
        microvm = mkOption {
          type = types.str;
          default = "172.30.1";
        };
      };
    };

    ipv6 = {
      publicAddress = mkOption {type = types.str;}; # GUA, only used for internet access
      address = mkOption {type = types.str;}; # ULA, used for LAN communication
      # subnet size always /64
      gateway = mkOption {type = types.str;};

      subnet = {
        #TODO: add public addresses
        microvmHost = mkOption {
          type = types.str;
          default = "fda4:7b0e:05b2:0";
        };
        microvm = mkOption {
          type = types.str;
          default = "fda4:7b0e:05b2:1";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    networking.useDHCP = false;

    systemd.network = {
      enable = true;

      links = {
        # non-persistent MAC addrs
        "00-bridges" = {
          matchConfig = {Type = "bridge";};
          linkConfig = {MACAddressPolicy = "none";};
        };
      };

      netdevs = attrsets.mergeAttrsList [
        # Define VLANs
        (attrsets.mapAttrs' (name: vlan:
          nameValuePair "20-vl${toString vlan.id}-${name}" {
            netdevConfig = {
              Kind = "vlan";
              Name = "vl${toString vlan.id}";
            };
            vlanConfig.Id = vlan.id;
          })
        cfg.vlans)

        # Define VM bridges
        (attrsets.mapAttrs' (name: vlan:
          nameValuePair "25-vlbr${toString vlan.id}-${name}" {
            netdevConfig = {
              Name = "vlbr${toString vlan.id}";
              Kind = "bridge";
            };
          })
        cfg.vlans)
      ];

      networks = attrsets.mergeAttrsList [
        {
          # Setup uplink iface
          "10-uplink" = {
            matchConfig.Name = cfg.interface;
            networkConfig.DHCP = "no";
            networkConfig.IPv6AcceptRA = "no";
            address = [
              "${ipv4.address}/${toString ipv4.subnetSize}"
              "${ipv6.address}/64"
              "${ipv6.publicAddress}/64"
            ];
            routes = [
              {routeConfig.Gateway = ipv4.gateway;}
              {routeConfig.Gateway = ipv6.gateway;}
            ];
            linkConfig.RequiredForOnline = "routable";

            vlan = attrsets.mapAttrsToList (name: vlan: "vl${toString vlan.id}") cfg.vlans;
          };
        }

        # Connect VLANs to bridges
        (lib.attrsets.mapAttrs' (name: vlan:
          nameValuePair "30-vl${toString vlan.id}-${name}" {
            matchConfig.Name = "vl${toString vlan.id}";
            networkConfig.Bridge = "vlbr${toString vlan.id}";
            linkConfig.RequiredForOnline = "enslaved";
          })
        cfg.vlans)

        # Setup bridges
        (lib.attrsets.mapAttrs' (name: vlan:
          nameValuePair "35-vlbr${toString vlan.id}-${name}" {
            matchConfig.Name = "vlbr${toString vlan.id}";
            bridgeConfig = {};
            networkConfig.LinkLocalAddressing = "no";
            linkConfig.RequiredForOnline = "carrier";
          })
        cfg.vlans)

        # Setup MicroVM P2P interfaces
        (attrsets.mapAttrs' (_: vmData: (let
          mac = configLib.decToHex vmData.id "";
        in
          nameValuePair ("45-vmtap" + (toString vmData.id)) {
            matchConfig.Name = "vmtap" + (toString vmData.id);
            networkConfig = {
              ConfigureWithoutCarrier = "yes";
              LinkLocalAddressing = "no";
              DHCP = "no";
            };
            addresses = [
              {
                addressConfig = {
                  Address = "${ipv4.subnet.microvmHost}.${toString vmData.id}/32";
                  Peer = "${ipv4.subnet.microvm}.${toString vmData.id}/32";
                };
              }
              {
                addressConfig = {
                  Address = "${ipv6.subnet.microvmHost}::${toString vmData.id}/128";
                  Peer = "${ipv6.subnet.microvm}::${toString vmData.id}/128";
                };
              }
            ];
            linkConfig.MACAddress = "02:00:00:00:00:${
              if stringLength mac == 1
              then "0"
              else ""
            }${mac}";
            linkConfig.RequiredForOnline = "routable";
            extraConfig = let
              fullMAC = "02:00:00:00:01:${
                if stringLength mac == 1
                then "0"
                else ""
              }${mac}";
            in ''
              [Neighbor]
              Address=${ipv4.subnet.microvm}.${toString vmData.id}
              LinkLayerAddress=${fullMAC}

              [Neighbor]
              Address=${ipv6.subnet.microvm}::${toString vmData.id}
              LinkLayerAddress=${fullMAC}
            '';
          }))
        (filterAttrs (_: vm: vm.enable) config.cfg.server.microvm.vms))
      ];
    };
  };
}
