{
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) vmConf vms net;
  inherit (net) ipv4 ipv6;
in {
  cfg.core = {
    net = {
      dns.enable = mkDefault true;
      dns.nameservers = mkDefault [
        "${ipv6.subnet.microvm}::${toString vms.unbound.id}"
        "${ipv4.subnet.microvm}.${toString vms.unbound.id}"
      ];
    };
  };

  cfg.microvm = {
    host.enable = mkDefault true;
    net = {
      enable = mkDefault true;
    };
  };

  svc = {
    ssh.enable = mkDefault true;
    ssh.keys = mkDefault vmConf.sshKeys;
    endlessh.enable = mkDefault false;
  };
}
