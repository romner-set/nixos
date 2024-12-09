{
  config,
  configLib,
  lib,
  pkgs,
  unstable,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;
in {
  # ipv6 to ipv4 forwarding, since slskd can't do both natively
  systemd.services.slskd-6to4-web = {
    script =  "socat TCP6-LISTEN:5030,fork,ipv6only=1 TCP4:127.0.0.1:5030";
    wantedBy = ["multi-user.target"];
    path = [pkgs.socat];
  };
  systemd.services.slskd-6to4-slsk = {
    script =  "socat TCP6-LISTEN:50300,fork,ipv6only=1 TCP4:127.0.0.1:50300";
    wantedBy = ["multi-user.target"];
    path = [pkgs.socat];
  };

  systemd.services.slskd.serviceConfig.ReadOnlyPaths = mkForce [ "/music" ];
  services.slskd = {
    enable = true;
    openFirewall = true;

    domain = null;

    user = "vm-slskd";
    group = "vm-slskd";

    environmentFile = "/secrets/rendered/env";

    settings = {
      directories.incomplete = "/music/soulseek-unsorted/incomplete";
      directories.downloads = "/music/soulseek-unsorted";

      shares = {
        directories = [
          "/music"
          "!/music/soulseek-unsorted"
          "!/music/scripts" # TODO: put this into a proper git repo
          "!/music/yt-rips"
        ];

        cache = {
          storage_mode = "memory";
          workers = 16;
        };
      };

      global = {
        upload = {
          slots = 200;
          speed_limit = 40000; # KiB/s
        };
        limits.weekly.failures = 2000;
      };

      soulseek = {
        distributed_network = {
          disabled = false;
          disable_children = false;
          child_limit = 500;
        };

        connection.buffer = {
          read = 65536;
          write = 65536;
          transfer = 1048576;
        };
      };

      web.https.disabled = true;
      filters.search.request = ["^.{1,2}$"]; # discard any requests shorter than 3 characters

      retention.transfers.upload = {
        succeeded = 1440; # 1 day
        errored = 1440;
        cancelled = 60;
      };
    };
  };
}
