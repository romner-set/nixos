{lib, ...}:
with lib; {
  cfg.core = {
    firmware.enable = mkDefault true;
    firmware.allowUnfree = mkDefault false;
    boot.loader.grub.enable = mkDefault true;

    hardening.allowForwarding = mkDefault true;
    hardening.allowPing = mkDefault true;

    services = {
      ssh.enable = mkDefault true;
      endlessh.enable = mkDefault false;
    };

    net = {
      dns.enable = mkDefault true;
    };
  };
  
  networking.firewall.enable = false;
}
