{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.server.net.frr;
  inherit (config.cfg.server) net;
  inherit (net) ipv4 ipv6;
in {
  options.cfg.server.net.frr = {
    enable = mkEnableOption "";
    ospf.enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    /*
    services.frr.static = mkIf config.cfg.server.microvm.enable {
       enable = true;
       config = strings.concatStrings (attrsets.mapAttrsToList (name: vm: let
           id = toString vm.id;
         in ''
           ip route ${ipv4.subnet.microvm}.${id}/32 vmtap${id}
           ipv6 route ${ipv6.subnet.microvm}::${id}/128 vmtap${id}
           ipv6 route ${ipv6.subnet.microvmPublic}::${id}/128 vmtap${id}
         '')
         config.cfg.server.microvm.vms);
     };
    */

    sops.secrets.ospf-key = {};

    sops.templates."frr.conf" = {
      content = ''
        ! FRR Configuration
        !
        hostname ${config.networking.hostName}
               log syslog
               service password-encryption
               service integrated-vtysh-config
               !
        ! OSPF
        !
               key chain lan
               	key 0
               	key-string ${config.sops.placeholder.ospf-key}
               	cryptographic-algorithm hmac-sha-256
               !
               interface ${net.interface}
               	ip ospf area 0.0.0.0
               	ip ospf authentication key-chain lan
               	ipv6 ospf6 area 0.0.0.0
               	ipv6 ospf6 authentication keychain lan
               !
               router ospf
               	ospf router-id ${ipv4.address}
               	redistribute static
               	redistribute kernel
               	redistribute connected
               !
               router ospf6
               	ospf6 router-id ${ipv4.address}
               	redistribute static
               	redistribute kernel
               	redistribute connected
               !
               end
      '';
      owner = "frr";
    };

    services.frr.configFile = config.sops.templates."frr.conf".path;
    services.frr.ospfd.enable = cfg.ospf.enable;
    services.frr.ospf6d.enable = cfg.ospf.enable;
  };
}
