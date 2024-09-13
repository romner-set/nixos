{modulesPath, ...}: {
  networking.hostName = "endymion";
  networking.hostId = "3acb8e4a";
  system.stateVersion = "23.11";

  cfg.core.firmware.enable = true;
  cfg.core.boot.loader.grub.enable = true;

  cfg.desktop.environment.kde.enable = true;
  cfg.desktop.graphics.nvidia.enable = true;
  cfg.desktop.graphics.amdgpu.enable = true;

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
}
