{
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=8G" "mode=755"];
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "nvme/home";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "nvme/nix";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/etc/nixos" = {
    device = "nvme/nix/nixos";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = ["umask=007"];
  };

  swapDevices = [
    {
      device = "/dev/zvol/nvme/swap";
      randomEncryption = {
        enable = true;
        source = "/dev/random";
      };
    }
  ];
}
