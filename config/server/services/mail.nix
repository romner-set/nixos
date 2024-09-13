{
  config,
  configLib,
  lib,
  pkgs,
  sops,
  ...
}:
with lib; let
  cfg = config.cfg.server.services.mail;
in {
  options.cfg.server.services.mail = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    sops.secrets."mail" = {};

    programs.msmtp = {
      enable = true;
      setSendmail = true;
      defaults = {
        aliases = "/etc/aliases";
        port = 465;
        tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
        tls = "on";
        auth = "login";
        tls_starttls = "off";
        set_from_header = "on";
      };
      accounts = {
        default = {
          host = "mail.${config.networking.domain}";
          passwordeval = "cat /run/secrets/mail";
          user = "${config.networking.hostName}@${config.networking.domain}";
          from = "${config.networking.hostName}@${config.networking.domain}";
        };
      };
    };
    environment.etc."aliases".text = "root: alerts@${config.networking.domain}";

    services.zfs.zed.settings = {
      ZED_EMAIL_ADDR = ["root"];
      ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
      ZED_EMAIL_OPTS = "@ADDRESS@";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = false;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };
}
