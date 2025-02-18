{
  config,
  lib,
  pkgs,
  modulesPath,
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
    boot.loader.grub.enable = true;
    net.systemdDefault = true;
  };

  cfg.desktop = {
    graphics.nvidia.enable = true;
    #boot.plymouth.enable = true;

    environment.kde = lib.mkIf (config.specialisation != {}) {
      enable = true;
      autoLogin.user = "main";
    };
  };

  specialisation.Hyprland.configuration.cfg.desktop.environment.hyprland = let
    primaryM = "desc:AOC 32G1WG4 0x00001165";
    secondaryM = "desc:Microstep MSI MAG275R 0x0000037E";
  in {
    enable = true;
    autoLogin.user = "main";

    services.hyprpaper.monitors.${primaryM}.wallpaper = "space.jpg";
    services.hyprpaper.monitors.${secondaryM}.wallpaper = "abstract-portrait.jpg";

    monitors = {
      ${primaryM} = {
        resolution = "1920x1080@144";
        position = "1080x400";
      };
      ${secondaryM} = {
        position = "0x0";
        extraArgs = ", transform, 3"; # 270deg
      };
    };
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
