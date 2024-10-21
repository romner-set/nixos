{modulesPath, ...}: {
  networking.hostName = "endymion";
  networking.hostId = "3acb8e4a";
  system.stateVersion = "23.11";

  cfg.core.firmware.enable = true;
  cfg.core.boot.loader.grub.enable = true;
  cfg.core.net.systemdDefault = true;

  cfg.desktop.graphics.nvidia.enable = true;
  cfg.desktop.graphics.amdgpu.enable = true;

  cfg.desktop.environment.kde = {
    enable = true;
    session = "plasmax11";
    autoLogin.user = "main";
  };

  cfg.server.libvirt.enable = true;
  cfg.server.libvirt.vfio = false;
  users.users.main.extraGroups = ["libvirtd"];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
}
