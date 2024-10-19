{
  config,
  lib,
  pkgs,
  domain,
  ...
}:
with lib; let
  inherit (config.networking) domain hostName;
  inherit (config.cfg.microvm.host) vms net;
  inherit (net) ipv4 ipv6;
in {
  systemd.services.coturn.serviceConfig = {
    # allow reading secrets
    User = mkForce "root";
    Group = mkForce "root";
  };
  services.coturn = {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49152;
    max-port = 65535;
    use-auth-secret = true;
    static-auth-secret-file = "/secrets/shared";
    realm = "turn.${domain}";
    cert = "/ssl/${domain}/full.pem";
    pkey = "/ssl/${domain}/key.pem";
    extraConfig = ''
      external-ip=${ipv4.publicAddress}
    '';
  };
}
