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
    zfs.requestEncryptionCredentials = ["nvme" "hdd" "archive"];
    kernelParams = ["zfs.zfs_arc_max=8589934592"]; # 8G
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

  fileSystems."/var/lib/microvms" = {
    device = "nvme/microvm";
    fsType = "zfs";
    #options = ["noexec" "nodev"];
  };

  fileSystems."/vm" = {
    device = "nvme/microvm/vm-data";
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

  fileSystems."/var/log" = {
    device = "nvme/nix/log";
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
}
