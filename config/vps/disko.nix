{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cfg.vps.disko;
in {
  options.cfg.vps.disko = {
    enable = mkEnableOption "";
    device = mkOption {
      type = types.str;
      default = "/dev/sda";
    };
  };

  config = mkIf cfg.enable {
    disko.devices = {
      disk = {
        root = {
          type = "disk";
          device = cfg.device;
          content = {
            type = "gpt";
            partitions = {
              EFI = {
                priority = 1;
                name = "EFI";
                start = "1M";
                end = "1024M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  extraArgs = ["-n EFI"];
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              ROOT = {
                end = "-8G";
                content = {
                  type = "btrfs";
                  extraArgs = ["-f -L ROOT"];
                  subvolumes = {
                    "@nix" = {
                      mountOptions = ["compress=zstd" "noatime"];
                      mountpoint = "/nix";
                    };
                    /*
                      "@nixos" = {
                      mountOptions = ["compress=zstd" "noatime"];
                      mountpoint = "/etc/nixos";
                    };
                    */
                    "@data" = {
                      mountOptions = ["compress=zstd" "noatime"];
                      mountpoint = "/data";
                    };
                  };
                  #mountpoint = "/btrfs";
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
      };
    };
  };
}
