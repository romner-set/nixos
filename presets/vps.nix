{
  lib,
  config,
  ...
}:
with lib; {
  cfg.core = {
    boot.loader.systemd-boot.enable = mkDefault true;

    services = {
      ssh.enable = mkDefault true;
      ssh.openFirewall = mkDefault true;
      ssh.ports = mkDefault [31832];
      endlessh.enable = mkDefault true;
    };

    net = {
      dns.enable = mkDefault true;
      dns.nameservers = mkDefault ["::1"];
    };
  };

  cfg.vps = {
    autoUpgrade.enable = true;
    disko.enable = true;
    misc.enable = true;

    services = {
      knot.enable = true;
      unbound.enable = true;
      #rathole.enable = true;
    };
  };
}
