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
        low = 768;
        mid = 2048;
        high = 12288;
      };
      vms = {
        # core
        nginx.enable = true;
        authelia.enable = true;
        nameserver.enable = true;
        unbound.enable = true;

        # media, storage
        koel.enable = true;
        caldav.enable = true;
        immich.enable = true;
        git.enable = true;
        git-runner.enable = true;

        # misc
        mail.enable = true;
        searxng.enable = true;
        llm.enable = true;
        tor-relay.enable = true;

        # gaming
        #foundryvtt.enable = true;
      };
    };

    net = {
      interface = "eno1";

      vlans = {
        "trusted" = {
          enable = true;
          id = 1010;
        };
        "untrusted" = {
          enable = true;
          id = 1020;
        };
      };

      ipv4 = {
        publicAddress = "93.185.10.73";
        address = "10.47.0.2";
        gateway = "10.47.0.1";
        subnetSize = 24;

        subnet = {
          microvm = "172.30.1";
          microvmHost = "172.30.0";
        };
      };

      ipv6 = {
        publicAddress = "2001:470:59b6::2";
        address = "fd95:3a23:dd1f::2";
        gateway = "fd95:3a23:dd1f::1";

        subnet = {
          microvm = "fda4:7b0e:05b2:1";
          microvmHost = "fda4:7b0e:05b2:0";
        };
      };
    };
  };
}
