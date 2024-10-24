{
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking.hostName = "artemis";
  networking.hostId = "9f3afe64";
  networking.domain = "cynosure.red";
  system.stateVersion = "23.11";

  cfg.core.firmware.enable = false;
  cfg.core.boot.loader.systemd-boot.enable = true;
  cfg.core.net.systemdDefault = true;

  cfg.desktop.graphics.nvidia.enable = true;

  cfg.desktop.environment.kde = {
    enable = true;
    autoLogin.user = "main";
  };

  cfg.desktop.services.sunshine = {
    enable = true;
    openFirewall = true;
    monitor = 1;
  };

  cfg.core.services.ssh = {
    enable = true;
    openFirewall = true;
    ports = [443];
  };

  cfg.desktop.boot.plymouth.enable = true;

  environment.systemPackages = with pkgs; [
    androidStudioPackages.canary
  ];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
}
