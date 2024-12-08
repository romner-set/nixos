{
  config,
  configLib,
  lib,
  pkgs,
  unstable,
  ...
}:
with lib; let
  domain = "iv.${config.networking.domain}";
in {
  services.postgresql.dataDir = "/data/db";

  services.nginx.virtualHosts.${domain} = {
    enableACME = false;
    forceSSL = false;
  };

  systemd.services.invidious.serviceConfig.LoadCredential = configLib.toCredential ["rendered/session.json"];
  services.invidious = {
    enable = true;
    inherit domain;
    package = unstable.invidious;

    database.createLocally = true;

    serviceScale = 8;
    nginx.enable = true;
    http3-ytproxy.enable = true;
    sig-helper.enable = true;

    extraSettingsFile = "/run/credentials/invidious.service/rendered-session.json";

    settings = {
      registration_enabled = false;
      captcha_enabled = false;

      channel_threads = 16;
      feed_threads = 16;
      https_only = mkForce true;

      default_user_preferences = {
        dark_mode = "dark";
        annotations = true;
        annotations_subscribed = true;

        autoplay = true;
        quality = "dash";
        quality_dash = "1440p"; # I only own 1080p screens but youtube compresses everything so much it's actually noticeable
        volume = 50;
        save_player_pos = true;

        local = true;
      };
    };
  };
}
