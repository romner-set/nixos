{
  lib,
  config,
  ...
}:
with lib; {
  # auto-backup
  services.cron.systemCronJobs = [
    "*/6  *  * * *   root    /run/current-system/sw/bin/zfs-autobackup --no-holds --clear-mountpoint --set-properties autobackup:${config.networking.hostName}-offsite=false ${config.networking.hostName}-local hdd/backups"
  ];
}
