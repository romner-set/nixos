{
  config,
  configLib,
  lib,
  pkgs,
  sops,
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

    services.frr.ospf = mkIf cfg.ospf.enable {
      enable = true;
      config = ''
        interface ${net.interface}
        	ip ospf area 0.0.0.0

        router ospf
        	ospf router-id ${ipv4.address}
        	redistribute static
      '';
    };

    services.frr.ospf6 = mkIf cfg.ospf.enable {
      enable = true;
      config = ''
        interface ${net.interface}
        	ipv6 ospf6 area 0.0.0.0

        router ospf6
        	ospf6 router-id ${ipv4.address}
        	redistribute static
      '';
    };
  };
}
