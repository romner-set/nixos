{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.microvm.host;
  inherit (config.networking) domain;
in {
  # globally recognized
  security.acme = {
    preliminarySelfsigned = false;
    acceptTerms = true;

    certs."${domain}" = {
      extraDomainNames = [
        "*.${domain}"
        "*.vm.${domain}"
      ];
      dnsResolver = "${config.cfg.server.net.ipv6.subnet.microvm}::${toString cfg.vms.nameserver.id}";
      #dnsResolver = "${cfg.vms.nameserver.name}.vm.${domain}";
      dnsPropagationCheck = true;

      group = "nginx";
      reloadServices = ["nginx"];
      server = "https://acme.zerossl.com/v2/DV90";
      email = "admin@${domain}";

      #mox mail doesn't support this as of yet: ocspMustStaple = true;
      keyType = "ec384";
      extraLegoRenewFlags = ["--reuse-key"]; # for static TLSA records

      dnsProvider = "rfc2136";
      environmentFile = "/secrets/rendered/acme.env";
    };

    # internal CA
    certs."internal-${domain}" = {
      inherit domain;
      extraDomainNames = [
        "*.${domain}"
        "*.vm.${domain}"
      ];
      dnsResolver = "${config.cfg.server.net.ipv6.subnet.microvm}::${toString cfg.vms.nameserver.id}";
      dnsPropagationCheck = true;

      validMinDays = 0; # short-lived certs, 28h by default -> 4h of use before renewal
      renewInterval = "hourly";

      group = "nginx";
      reloadServices = ["nginx"];
      server = "https://${cfg.vms.certs.name}.vm.${domain}/acme/acme/directory";
      email = "admin@${domain}";

      keyType = "ec384";
      extraLegoRenewFlags = ["--reuse-key"]; # for static TLSA records

      dnsProvider = "rfc2136";
      environmentFile = "/secrets/rendered/acme-internal.env";
    };
  };

  systemd.services."acme-internal-${domain}".wantedBy = lib.mkForce [];
  systemd.targets."acme-finished-internal-${domain}".wantedBy = lib.mkForce [];

  systemd.timers."acme-internal-${domain}".timerConfig = {
    AccuracySec = lib.mkForce 60;
    RandomizedDelaySec = lib.mkForce "5m";
  };
}
