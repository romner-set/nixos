{
  config,
  configLib,
  lib,
  pkgs,
  mail,
  sops,
  ...
}:
with lib; let
  cfg = config.cfg.server.services.tor;
  hostName = config.networking.hostName;
in {
  options.cfg.server.services.tor = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    ## Tor NAT traversal

    sops.secrets."tor/hostname" = {
      format = "binary";
      restartUnits = ["tor.service"];
      sopsFile = "/secrets/${hostName}/tor/hostname";
    };
    sops.secrets."tor/hs_ed25519_public_key" = {
      format = "binary";
      restartUnits = ["tor.service"];
      sopsFile = "/secrets/${hostName}/tor/hs_ed25519_public_key";
    };
    sops.secrets."tor/hs_ed25519_secret_key" = {
      format = "binary";
      restartUnits = ["tor.service"];
      sopsFile = "/secrets/${hostName}/tor/hs_ed25519_secret_key";
    };

    # during boot
    boot.initrd.secrets = {
      "/etc/tor/onion/bootup" = /run/secrets/tor;
    };
    boot.initrd.extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.tor}/bin/tor
    '';
    boot.initrd.network.postCommands = let
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
      tor -f ${torRc} --verify-config
      tor -f ${torRc} &
    '';

    # after boot
    services.tor = {
      enable = true;
      enableGeoIP = false;
      relay.onionServices = {
        ssh = {
          version = 3;
          map = [
            {
              port = 32998;
              target = {
                addr = "[::1]";
                port = 8;
              };
            }
          ];
        };
      };
      settings = {
        ClientUseIPv4 = true;
        ClientUseIPv6 = false;
        HiddenServiceSingleHopMode = true;
        HiddenServiceNonAnonymousMode = true;
      };
    };

    fileSystems."/var/lib/tor/onion/ssh/hostname" = {
      device = "/run/secrets/tor/hostname";
      options = ["bind" "r"];
    };
    fileSystems."/var/lib/tor/onion/ssh/hs_ed25519_public_key" = {
      device = "/run/secrets/tor/hs_ed25519_public_key";
      options = ["bind" "r"];
    };
    fileSystems."/var/lib/tor/onion/ssh/hs_ed25519_secret_key" = {
      device = "/run/secrets/tor/hs_ed25519_secret_key";
      options = ["bind" "r"];
    };
  };
}
