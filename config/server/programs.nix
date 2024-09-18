{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
with lib; let
  cfg = config.cfg.server.programs;
in {
  options.cfg.server.programs = {
    enable = mkEnableOption "";
    excludedPackages = mkOption {
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    ### PACKAGES ###
    environment.systemPackages = with pkgs;
      lists.subtractLists cfg.excludedPackages [
        # security
        ipset

        # backups
        unstable.zfs-autobackup
        mbuffer

        # misc
        lm_sensors
        cryptsetup # TODO
        virtiofsd
      ];
  };
}
