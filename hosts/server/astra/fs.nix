{
  lib,
  config,
  ...
}:
with lib; {
  boot = {
    # Mirror to /boot-fallback
    loader.grub.mirroredBoots = [
      {
        devices = [
          /*
          "/dev/disk/by-uuid/A871-4F42"
          */
          "nodev"
        ];
        path = "/boot-fallback";
      }
    ];

    ### ZFS CONFIG ###
    zfs.extraPools = ["hdd"];
    zfs.requestEncryptionCredentials = ["nvme" "hdd"];
    kernelParams = ["zfs.zfs_arc_max=17179869184"];
  };

  ### MOUNTS ###
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=24G"
      "mode=755"
    ];
  };

  fileSystems."/var/lib/libvirt" = {
    device = "nvme/libvirt";
    fsType = "zfs";
    #options = ["noexec"];
  };

  fileSystems."/keys" = {
    device = "nvme/keys";
    fsType = "zfs";
    neededForBoot = true;
    #options = ["noexec" "nodev"];
  };

  fileSystems."/secrets" = {
    device = "nvme/keys/nixos-secrets";
    fsType = "zfs";
    neededForBoot = true;
    #options = ["noexec" "nodev"];
  };

  fileSystems."/vm" = {
    device = "nvme/nix/vm-data";
    fsType = "zfs";
    #options = ["noexec" "nodev"];
  };

  fileSystems."/etc/nixos" = {
    device = "nvme/nix/nixos";
    fsType = "zfs";
    #options = ["noexec" "nodev"];
  };

  fileSystems."/nix" = {
    device = "nvme/nix";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A7FB-24B0";
    fsType = "vfat";
    #options = ["noexec" "nodev"];
  };

  fileSystems."/boot-fallback" = {
    device = "/dev/disk/by-uuid/A871-4F42";
    fsType = "vfat";
    #options = ["noexec" "nodev"];
  };

  # TEMPORARY
  fileSystems."/data" = {
    device = "nvme/old-secrets";
    fsType = "zfs";
    #options = ["noexec" "nodev"];
  };
}
