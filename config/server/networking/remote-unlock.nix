{
  config,
  configLib,
  pkgs,
  lib,
  sops,
  ...
}:
with lib; let
  cfg = config.cfg.server.net.remoteUnlock;
  net = config.cfg.server.net;
  inherit (net) ipv4 ipv6;
in {
  options.cfg.server.net.remoteUnlock = {
    enable = mkEnableOption "";
    sshPort = mkOption {
      type = types.port;
      default = 22;
    };
    dns = mkOption {
      type = types.str;
      default = "9.9.9.9";
    };
  };

  config = mkIf cfg.enable {
    boot.kernelParams = [
      "ip=${ipv4.address}::${ipv4.gateway}:${configLib.subnet.lengthToMask ipv4.subnetSize}:${config.networking.hostName}:${net.interface}:off:${cfg.dns}::"
    ];

    sops.secrets."etc/ssh/ssh_host_ed25519_key.pub.initrd" = {};
    sops.secrets."etc/ssh/ssh_host_ed25519_key.initrd" = {};

    boot.initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        hostKeys = ["/run/secrets/etc/ssh/ssh_host_ed25519_key.initrd"];
        authorizedKeys = config.cfg.core.services.ssh.keys;
        port = cfg.sshPort;
      };
    };

    # tor
    boot.initrd.secrets = mkIf config.cfg.server.services.tor.enable {
      "/etc/tor/onion/bootup" = /run/secrets/tor;
    };
    boot.initrd.extraUtilsCommands = mkIf config.cfg.server.services.tor.enable ''
      copy_bin_and_libs ${pkgs.tor}/bin/tor
    '';
    boot.initrd.network.postCommands = strings.concatStrings [
      # zfs
      (
        if config.cfg.server.disks.zfs.enable
        then ''
          echo 'zfs load-key -a; zfs mount -a; killall zfs; rm -r /run/secrets' >> /root/.profile
        ''
        else ""
      )

      (
        if config.cfg.server.services.tor.enable
        then
          (let
            torRc = pkgs.writeText "tor.rc" ''
              DataDirectory /etc/tor
              HiddenServiceDir /etc/tor/onion/bootup
              HiddenServicePort 32998 [::1]:8
              #HiddenServiceSingleHopMode 1
              #HiddenServiceNonAnonymousMode 1
            '';
          in ''
            echo "tor: preparing onion folder"
            chmod -R 700 /etc/tor

            echo "make sure localhost is up"
            ip a a 127.0.0.1/8 dev lo
            ip a a ::1/128 dev lo
            ip link set lo up

            echo "tor: starting tor"
            #tor -f ${torRc} --verify-config
            #tor -f ${torRc} &
          '')
        else ""
      )
    ];
  };
}
