{config, ...}: {
  networking.hostName = "paraline";
  networking.hostId = "b94c87af";
  networking.domain = "cynosure.red";

  cfg.core.services.ssh.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMoGjgLjnlWmpGB+FSbSromjhnL1PRpnzBboXxDXtlw9"];
  cfg.core.services.ssh.openFirewall = true;
  cfg.core.firmware.microcode = "intel";

  cfg.server.disks.zfs.enable = true;
  cfg.server.disks.sataMaxPerf = true;

  boot.extraModprobeConfig = ''
    options ixgbe allow_unsupported_sfp=1
  '';

  system.stateVersion = config.system.nixos.release; # root is on tmpfs, this should be fine

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "ixgbe" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
}
