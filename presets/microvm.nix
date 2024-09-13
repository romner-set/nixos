{
  lib,
  hostNetwork,
  vms,
  vmConf,
  ...
}:
with lib; {
  cfg.core = {
    services = {
      ssh.enable = mkDefault true;
      ssh.keys = mkDefault vmConf.sshKeys;
      endlessh.enable = mkDefault false;
    };
    net = {
      dns.enable = mkDefault true;
      dns.nameservers = let
        inherit (hostNetwork) ipv4 ipv6;
      in
        mkDefault [
          "${ipv6.subnet.microvm}::${toString vms.unbound.id}"
          "${ipv4.subnet.microvm}.${toString vms.unbound.id}"
        ];
    };
  };

  cfg.microvm = {
    net = {
      enable = mkDefault true;
    };
  };
}
