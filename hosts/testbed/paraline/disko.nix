{
  config,
  lib,
  ...
}:
with lib; let
  hostname = config.networking.hostName;
  diskConf = disk: bootMount: {
    type = "disk";
    device = disk;
    content = {
      type = "gpt";
      partitions = {
        EFI = {
          priority = 1;
          start = "1M";
          end = "1024M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = bootMount;
          };
        };
        ZFS = {
          end = "-4G";
          content = {
            type = "zfs";
            pool = hostname;
          };
        };
        SWAP = {
          size = "100%";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        };
      };
    };
  };
in {
  disko.devices = {
    disk = {
      sda = diskConf "/dev/disk/by-id/ata-WDC_WD1600JS-00NCB1_WD-WMANM1395814" "/boot";
      sdb = diskConf "/dev/disk/by-id/ata-ST3160811AS_6PT0WASM" "/boot-sdb";
      sdc = diskConf "/dev/disk/by-id/ata-ST3160813AS_9YP07LRC" "/boot-sdc";
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=4G"
        "defaults"
        "mode=755"
      ];
    };

    zpool."${hostname}" = {
      type = "zpool";
      rootFsOptions.compression = "zstd";
      rootFsOptions.canmount = "off";
      rootFsOptions.mountpoint = mkForce "none";

      datasets = {
        "nix" = {
          type = "zfs_fs";
	  options.mountpoint = "legacy";
          mountpoint = "/nix";
        };
        "nix/nixos" = {
          type = "zfs_fs";
	  options.mountpoint = "legacy";
          mountpoint = "/etc/nixos";
        };
        "nix/logs" = {
          type = "zfs_fs";
	  options.mountpoint = "legacy";
          mountpoint = "/var/log";
        };
      };
    };
  };
}
