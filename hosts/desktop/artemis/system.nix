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

  cfg.core = {
    firmware.enable = false;
    boot.loader.systemd-boot.enable = true;
    net.systemdDefault = true;
  };

  cfg.desktop = {
    graphics.nvidia.enable = true;
    environment.kde = {
      enable = true;
      autoLogin.user = "main";
    };

    boot.plymouth.enable = true;
  };

  svc = {
    ssh = {
      enable = true;
      openFirewall = true;
      ports = [443];
    };

    sunshine = {
      enable = true;
      openFirewall = true;
      monitor = 1;
    };
  };

  environment.systemPackages = with pkgs; [
    androidStudioPackages.canary
  ];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
}
