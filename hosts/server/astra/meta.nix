{
  lib,
  config,
  ...
}:
with lib; {
  networking.hostName = "astra";
  networking.hostId = "a6b703c2";
  networking.domain = "cynosure.red";
  system.stateVersion = "23.11";

  # NOTE: this file is directly imported by microVMs, so needs to be available in all servers using them
  cfg.server = {
    microvm = {
      enable = true;
      vmConf.sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnFDhRTJyoFdhs31OHXvQwcQY3SlB9WX0bUCTlJKdJO root@astra"
      ];
      defaults.mem = {
        low = 1024;
        mid = 2560;
        high = 12288;
      };
      vms = {
        # core/critical
        nginx.enable = true;
        authelia.enable = true;
        nameserver.enable = true;
        certs.enable = true;
        unbound.enable = true;
        searxng.enable = true;

        # federated
        mail.enable = true;
        matrix.enable = true;
        element.enable = true;

        # music
        #koel.enable = true;
        #swingmusic.enable = true;
        #meelo.enable = true;
        navidrome.enable = true;
        slskd.enable = true;

        # media
        immich.enable = true;
        starr.enable = true;
        jellyfin.enable = true;
        qbittorrent.enable = true;
        invidious.enable = true;

        # other storage
        srv.enable = true;
        caldav.enable = true;
        git.enable = true;
        git-runner.enable = true;
        samba.enable = true;

        # task mgmt
        uptime.enable = true;
        vikunja.enable = true;
        kitchenowl.enable = true;

        # misc
        owntracks.enable = true;
        llm.enable = true;
        tor.enable = true;
        turn.enable = true;

        # network
        #librenms.enable = true;

        # gaming
        #foundryvtt.enable = true;
	mc.enable = true;
      };
    };

    net = {
      interface = "eno1";

      frr.ospf.enable = true;

      bridges = {
        # libvirt bridges
        vbr-trusted = {
          enable = true;
          ipv4 = "172.20.0.1/24";
          ipv6 = "2001:470:59b6:a39d::/64";
        };
        vbr-untrusted = {
          enable = true;
          ipv4 = "172.20.1.1/24";
          ipv6 = "2001:470:59b6:d857::/64";
        };
      };

      dontSetGateways = true; # discovered w/ OSPF

      ipv4 = {
        publicAddress = "93.185.10.73";
        address = "10.47.0.2";
        gateway = "10.47.0.1"; # used for remote unlock only
        subnetSize = 24;

        subnet.microvm = "172.30.1";

        trustedNetworks = [
          "10.47.0.0/24"
          "10.47.10.0/24"
          "100.74.0.0/16"
          "172.20.0.0/24"
        ];
      };

      ipv6 = {
        publicAddress = "2001:470:59b6::2";
        address = "fd95:3a23:dd1f::2";
        #gateway = "fd95:3a23:dd1f::1";

        subnet = {
          microvm = "fda4:7b0e:05b2:1";
          microvmPublic = "2001:470:6f:389";
        };

        trustedNetworks = [
          "fd95:3a23:dd1f::/64"
          "fd95:3a23:dd1f:10::/64"
          "2001:470:59b6::/64"
          "2001:470:59b6:10::/64"
          "2001:470:59b6:407a::/64"
          "2001:470:59b6:a39d::/64"
        ];
      };
    };
  };
}
