{
  config,
  configLib,
  lib,
  pkgs,
  sops,
  ...
}:
with lib; let
  cfg = config.cfg.server.services.mullvad;
in {
  options.cfg.server.services.mullvad = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.mullvad-vpn pkgs.mullvad pkgs.nftables];
    services.mullvad-vpn.enable = true;

    sops.secrets."mullvad" = {};

    systemd.services."mullvad-daemon".after = mkIf config.cfg.server.microvm.enable ["microvms.target"];
    /*
    systemd.services."mullvad-daemon".postStart = let
      mullvad = config.services.mullvad-vpn.package;
      nft = pkgs.nftables;
      awk = pkgs.gawk;
    in ''
      while ! ${mullvad}/bin/mullvad status >/dev/null; do sleep 1; done
      ${mullvad}/bin/mullvad account login $(cat /run/secrets/mullvad)
      ${mullvad}/bin/mullvad lan set allow

      echo 'nameserver ${ipv6.prefix}${ipv6.subnet.microvm}::${toString vm.unbound.id}
      nameserver ${ipv4.subnet.microvm}.${toString vm.unbound.id}
      options edns0 trust-ad' > /etc/resolv.conf
      ${mullvad}/bin/mullvad dns set custom ${ipv6.prefix}${ipv6.subnet.microvm}::${toString vm.unbound.id} ${ipv4.subnet.microvm}.${toString vm.unbound.id}
    '';
    /*''
      ${mullvad}/bin/mullvad connect
      while [ "$(${mullvad}/bin/mullvad status | ${awk}/bin/awk 'NR==1{print $1}')" != "Connected" ]; do sleep 0.5; done

      ${nft}/bin/nft flush chain inet mullvad forward
      ${nft}/bin/nft flush chain inet mullvad output
      ${nft}/bin/nft flush chain inet mullvad input
      ${nft}/bin/nft chain inet mullvad forward \{ policy accept\; \}
      ${nft}/bin/nft chain inet mullvad output \{ policy accept\; \}
      ${nft}/bin/nft chain inet mullvad input \{ policy accept\; \}

      #systemctl restart tor || true
      #netbird down && netbird up
    ''; #
    */

    /*
      #TODO: systemd.timers."mullvad-ensure-internet" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "3s";
        OnUnitActiveSec = "3s";
        AccuracySec = "1s";
        Unit = "mullvad-ensure-internet.service";
      };
    };

    systemd.services."mullvad-ensure-internet" = {
      script = let
        mullvad = config.services.mullvad-vpn.package;
        awk = pkgs.gawk;
      in ''
        if [ "$(${mullvad}/bin/mullvad status | ${awk}/bin/awk 'NR==1{print $1}')" != "Connecting" ]; then
                ${pkgs.iputils}/bin/ping -q -c1 -W0.1 9.9.9.9 || (${mullvad}/bin/mullvad disconnect; ${pkgs.mullvad-vpn}/bin/mullvad connect)
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        LogLevelMax = "emerg";
      };
      requires = ["mullvad-daemon.service"];
    }; #
    */

    /*
      #TODO: systemd.timers."mullvad-allow-dns" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "3s";
        OnUnitActiveSec = "3s";
        AccuracySec = "1s";
        Unit = "mullvad-allow-dns.service";
      };
    };

    systemd.services."mullvad-allow-dns" = {
      script = ''
        ${pkgs.nftables}/bin/nft -a list chain inet mullvad forward | ${pkgs.gawk}/bin/awk '/dport 53 reject/ {print $(NF)}' | xargs -r -n1 ${pkgs.nftables}/bin/nft delete rule inet mullvad forward handle
        ${pkgs.nftables}/bin/nft -a list chain inet mullvad output | ${pkgs.gawk}/bin/awk '/dport 53 reject/ {print $(NF)}' | xargs -r -n1 ${pkgs.nftables}/bin/nft delete rule inet mullvad output handle
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        LogLevelMax = "emerg";
      };
      requires = ["mullvad-daemon.service"];
    };

    /*
      systemd.services."microvm@" = rec {
      postStart = "timeout 1s systemctl start mullvad-allow-dns.service || true";
      postStop = postStart;
    };#
    */
  };
}
