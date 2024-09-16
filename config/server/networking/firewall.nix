{
  config,
  configLib,
  lib,
  pkgs,
  sops,
  ...
}:
with lib; let
  cfg = config.cfg.server.net;
  vms = config.cfg.server.microvm.vms;
  inherit (cfg) ipv4 ipv6;
  inherit (config.networking) hostName;
in {
  options.cfg.server.net.firewall = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable && cfg.firewall.enable) {
    sops.secrets."iptables/rules.v4" = {
      format = "binary";
      restartUnits = ["firewall.service"];
      sopsFile = "/secrets/${hostName}/iptables/rules.v4";
    };
    sops.secrets."iptables/rules.v6" = {
      format = "binary";
      restartUnits = ["firewall.service"];
      sopsFile = "/secrets/${hostName}/iptables/rules.v6";
    };
    sops.secrets."iptables/ipsets" = {
      format = "binary";
      restartUnits = ["firewall.service"];
      sopsFile = "/secrets/${hostName}/iptables/ipsets";
    };

    networking = {
      firewall.enable = true;

      firewall = {
        extraCommands = with strings; let
          vmsSorted = lists.sort (a: b: a.value.id > b.value.id) (attrsets.mapAttrsToList (name: value: {inherit name value;}) vms);
          # ^ needed otherwise e.g. vmtap12 would be matched by vmtap1 first
        in ''
          sleep 1

          ${concatStrings (map ({
              name,
              value,
            }: ''
              sed -i "s/MICROVM_${toUpper name}_IFACE/vmtap${toString value.id}/g" /run/secrets/iptables/rules.v{4,6}
              sed -i "s/MICROVM_${toUpper name}/${ipv6.subnet.microvm}::${toString value.id}/g" /run/secrets/iptables/rules.v6
              sed -i "s/MICROVM_${toUpper name}/${ipv4.subnet.microvm}.${toString value.id}/g" /run/secrets/iptables/rules.v4
            '')
            vmsSorted)}

          sed -i "s/SELF_ADDR/${ipv4.address}/g" /run/secrets/iptables/rules.v4
          sed -i "s/SELF_ADDR/${ipv6.address}/g" /run/secrets/iptables/rules.v6
          sed -i "s/SELF_PUBLIC_ADDR/${ipv6.publicAddress}/g" /run/secrets/iptables/rules.v6

          ipset restore -exist < /run/secrets/iptables/ipsets
          iptables-restore /run/secrets/iptables/rules.v4
          ip6tables-restore /run/secrets/iptables/rules.v6

          sed -i "s/${ipv4.address}/SELF_ADDR/g" /run/secrets/iptables/rules.v4
          sed -i "s/${ipv6.address}/SELF_ADDR/g" /run/secrets/iptables/rules.v6
          sed -i "s/${ipv6.publicAddress}/SELF_PUBLIC_ADDR/g" /run/secrets/iptables/rules.v6

          ${concatStrings (map ({
              name,
              value,
            }: ''
              sed -i "s/vmtap${toString value.id}/MICROVM_${toUpper name}_IFACE/g" /run/secrets/iptables/rules.v{4,6}
              sed -i "s/${ipv6.subnet.microvm}::${toString value.id}/MICROVM_${toUpper name}/g" /run/secrets/iptables/rules.v6
              sed -i "s/${ipv4.subnet.microvm}.${toString value.id}/MICROVM_${toUpper name}/g" /run/secrets/iptables/rules.v4
            '')
            vmsSorted)}
        '';
        extraPackages = [pkgs.ipset pkgs.iproute2];
      };
    };
  };
}
