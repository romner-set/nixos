{
  config,
  lib,
  pkgs,
  domain,
  ...
}:
with lib; let
  inherit (config.networking) domain hostName;
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
    min-port = 8888;
    max-port = 8888;
    use-auth-secret = true;
    static-auth-secret-file = "/secrets/shared";
    realm = "turn.${domain}";
    cert = "/ssl/${domain}/full.pem";
    pkey = "/ssl/${domain}/key.pem";
    secure-stun = true;
  };
}
