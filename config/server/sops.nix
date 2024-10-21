{
  config,
  configLib,
  sops,
  lib,
  ...
}:
with lib; let
  cfg = config.cfg.server.sops;
  #inherit (config.networking) hostName;
in {
  options.cfg.server.sops = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    users.users.microvm.extraGroups = ["keys"]; # allow access to sops secrets

    systemd.services."create-sops-symlink" = {
      script = ''
        mkdir -p /root/.config/sops/age
        ln -sf ${config.sops.age.keyFile} /root/.config/sops/age/keys.txt 2>/dev/null
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        LogLevelMax = "emerg";
      };
      wantedBy = ["default.target"];
    };

    sops.validateSopsFiles = false; # secrets outside config
    sops.defaultSopsFile = "/secrets/${config.networking.hostName}/misc.yaml";
    sops.age.keyFile = "/keys/age.key";
    sops.keepGenerations = 0; # don't delete old gens on `nixos-rebuild switch`, see https://github.com/astro/microvm.nix/issues/239

    # /etc persistent files
    sops.secrets."etc/machine-id" = {};
    sops.secrets."etc/ssh/ssh_host_ed25519_key.pub" = {};
    sops.secrets."etc/ssh/ssh_host_ed25519_key" = {};
    environment.etc."machine-id".source = "/run/secrets/etc/machine-id";
    environment.etc."ssh/ssh_host_ed25519_key".source = "/run/secrets/etc/ssh/ssh_host_ed25519_key";
    environment.etc."ssh/ssh_host_ed25519_key.pub".source = "/run/secrets/etc/ssh/ssh_host_ed25519_key.pub";
  };
}
