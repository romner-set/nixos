{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.server.disks;
in {
  options.cfg.server.disks = {
    zfs.enable = mkEnableOption "";
    sataMaxPerf = mkEnableOption ""; # necessary for hotswapping
    standbyOnBoot = {
      enable = mkEnableOption "";
      disks = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  };

  config = {
    ### ZFS ###
    boot.kernelPackages = mkIf cfg.zfs.enable config.boot.zfs.package.latestCompatibleLinuxPackages;
    boot.loader.grub.zfsSupport = mkForce cfg.zfs.enable;
    boot.zfs.package = mkIf cfg.zfs.enable pkgs.zfs_unstable;

    services.zfs = mkIf cfg.zfs.enable {
      trim.enable = mkDefault true;
      autoScrub.enable = mkDefault true;
    };

    ### SATA POWER MODE ###
    systemd.services."set-sata-powermode" = mkIf cfg.sataMaxPerf {
      script = ''
        for policy in /sys/class/scsi_host/host*/link_power_management_policy; do
          echo max_performance > $policy
        done
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      wantedBy = ["default.target"];
    };

    ### DISK STANDBY ###
    systemd.services."set-disks-standby" = mkIf cfg.standbyOnBoot.enable {
      script = ''
        for disk in ${strings.concatStrings (strings.intersperse " " cfg.standbyOnBoot.disks)}; do
          ${pkgs.hdparm}/bin/hdparm -y $disk
        done
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      wantedBy = ["default.target"];
    };
  };
}
