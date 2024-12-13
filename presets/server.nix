{
  lib,
  config,
  ...
}:
with lib; {
  cfg.core = {
    firmware.enable = mkDefault true;
    firmware.allowUnfree = mkDefault false;
    boot.loader.grub.enable = mkDefault true;

    hardening.allowForwarding = mkDefault true;

    net = {
      dns.enable = mkDefault true;
      dns.nameservers = let
        vms = config.cfg.server.microvm.vms;
        inherit (config.cfg.server.net) ipv4 ipv6;
      in
        mkDefault [
          "${ipv6.subnet.microvm}::${toString vms.unbound.id}"
          "${ipv4.subnet.microvm}.${toString vms.unbound.id}"
        ];
    };
  };

  cfg.server = {
    disks.zfs.enable = mkDefault true;
    disks.sataMaxPerf = mkDefault true; #hotswap

    ## reqs. further host-side config
    libvirt.enable = mkDefault true;
    microvm.enable = mkDefault true;
    net.enable = mkDefault true;
    ##

    net.frr.enable = mkDefault true;

    net.remoteUnlock = {
      enable = mkDefault true;
      sshPort = mkDefault 47;
    };

    sops.enable = mkDefault true;
    programs.enable = mkDefault true;
  };

  svc = {
    ssh.enable = mkDefault true;
    ssh.openFirewall = mkDefault false;
    ssh.ports = mkDefault [47];
    endlessh.enable = mkDefault true;

    cron.enable = mkDefault true;
    mail.enable = mkDefault true;
  };
}
