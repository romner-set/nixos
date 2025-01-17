{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  inherit (config.networking) domain;
in {
  services.postgresql = {
    package = pkgs.postgresql_15;
    dataDir = "/data/db";
  };
  services.forgejo = {
    enable = true;
    #useWizard = true;
    stateDir = "/data/forgejo";

    database.type = "postgres";
    lfs.enable = true;

    settings = {
      session.COOKIE_SECURE = true;
      service.DISABLE_REGISTRATION = true;

      server = rec {
        DOMAIN = "git.${domain}";
        ROOT_URL = "https://git.${domain}/";
        HTTP_PORT = 3000;
      };

      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "https://code.forgejo.org";
      };

      ui = {
        DEFAULT_THEME = "forgejo-dark";
        SHOW_USER_EMAIL = false;
      };

      repository = {
        ENABLE_PUSH_CREATE_USER = true;
        ENABLE_PUSH_CREATE_ORG = true;
      };

      # Sending emails is completely optional
      # You can send a test email from the web UI at:
      # Profile Picture > Site Administration > Configuration >  Mailer Configuration
      mailer = {
        ENABLED = true;
        SMTP_ADDR = "mail.${domain}";
        FROM = "git@${domain}";
        USER = "git@${domain}";
      };
    };
    #mailerPasswordFile = "/secrets/mail_pass";
  };
}
