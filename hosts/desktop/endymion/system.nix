{modulesPath, ...}: {
  networking.hostName = "endymion";
  networking.hostId = "3acb8e4a";
  networking.domain = "cynosure.red";
  system.stateVersion = "23.11";

  cfg.core = {
    firmware.enable = true;
    boot.loader.grub.enable = true;
    net.systemdDefault = true;
  };

  cfg.desktop = {
    graphics.nvidia.enable = true;
    graphics.amdgpu.enable = true;

    graphics.nvidia.prime = {
      enable = true;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    environment.kde = {
      enable = true;
      session = "plasmax11";
      autoLogin.user = "main";
    };
  };

  cfg.server = {
    libvirt.enable = true;
    libvirt.vfio = false;
  };
  users.users.main.extraGroups = ["libvirtd"];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
}
