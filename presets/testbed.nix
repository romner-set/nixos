{lib, ...}:
with lib; {
  cfg.core = {
    firmware.enable = mkDefault true;
    firmware.allowUnfree = mkDefault false;
    boot.loader.grub.enable = mkDefault true;

    hardening.allowForwarding = mkDefault true;
    hardening.allowPing = mkDefault true;

    net = {
      dns.enable = mkDefault true;
    };
  };

  svc = {
    ssh.enable = mkDefault true;
    endlessh.enable = mkDefault false;
  };

  networking.firewall.enable = false;
}
