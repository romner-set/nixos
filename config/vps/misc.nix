{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cfg.vps.misc;
in {
  options.cfg.vps.misc = {
    enable = mkEnableOption "";
    tmpfs.size = mkOption {
      type = types.str;
      default = "2G";
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.availableKernelModules = ["xhci_pci" "sr_mod" "virtio_net" "virtio_pci" "virtio_mmio" "virtio_blk" "virtio_scsi" "9p" "9pnet_virtio"];
    boot.initrd.kernelModules = ["virtio_balloon" "virtio_console" "virtio_rng" "virtio_gpu"];

    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=${cfg.tmpfs.size}" "mode=755"];
    };

    systemd.network.enable = true;
    networking.useDHCP = false;

    system.stateVersion = config.system.nixos.release; # / is on tmpfs, so this should be fine
  };
}
