{
  lib,
  config,
  ...
}: {
  networking.hostName = "endymion";
  networking.hostId = "3acb8e4a";
  networking.domain = "cynosure.red";
  system.stateVersion = config.system.nixos.release; # / is on tmpfs, so this should be fine

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

    environment.hyprland = lib.mkIf (config.specialisation != {}) {
      enable = true;
      autoLogin.user = "main";

      services.waybar.tempSensor = "/sys/class/hwmon/hwmon3/temp1_input";
      services.hyprpaper.monitors."".wallpaper = "aurora.jpg";
    };
  };

  specialisation.KDE.configuration.cfg.desktop.environment.kde = {
    enable = true;
    session = "plasmax11";
    autoLogin.user = "main";
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
