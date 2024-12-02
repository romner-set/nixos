{
  lib,
  pkgs,
  config,
  configLib,
  ...
}: let
  cfg = config.cfg.microvm.host;
  inherit (config.networking) domain;
in {
  # globally recognized
  security.acme = {
    preliminarySelfsigned = false;
    acceptTerms = true;
    
    defaults = {
      dnsResolver = "${config.cfg.server.net.ipv6.subnet.microvm}::${toString cfg.vms.nameserver.id}";
      #dnsResolver = "${cfg.vms.nameserver.name}.vm.${domain}";
      reloadServices = ["nginx"];

      group = "vm-nginx";
    };

    certs."${domain}" = {
      extraDomainNames = [
        "*.${domain}"
        "*.vm.${domain}"
      ];
      dnsPropagationCheck = true;

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
      validMinDays = 0; # short-lived certs, 28h by default -> 4h of use before renewal
      renewInterval = "hourly";

      server = "https://${cfg.vms.certs.name}.vm.${domain}/acme/acme/directory";
      email = "admin@${domain}";

      keyType = "ec384";
      extraLegoRenewFlags = ["--reuse-key"]; # for static TLSA records

      dnsProvider = "rfc2136";
      environmentFile = "/secrets/rendered/acme-internal.env";
    };
  };

    # don't block the boot sequence if a cert needs renewal - prevents microvm start timeout
  systemd.services."acme-${domain}".serviceConfig.Type = lib.mkForce "simple";
  systemd.services."acme-internal-${domain}".serviceConfig.Type = lib.mkForce "simple";

  # internal renewal is hourly, so having a randomized delay of 24h doesn't make much sense
  systemd.timers."acme-internal-${domain}".timerConfig = {
    AccuracySec = lib.mkForce 60;
    RandomizedDelaySec = lib.mkForce "5m";
  };
}
