{
  lib,
  pkgs,
  config,
  ...
}: with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;
in {
  users.users.vikunja = {
    isSystemUser = true;
    shell = pkgs.fish;
    group = "vikunja";
  };
  users.groups.vikunja = {};

  systemd.services.vikunja.serviceConfig = {
    User = "vikunja";
    DynamicUser = mkForce false;
    BindPaths = ["/data"];
  };

  services.vikunja = {
    enable = true;

    frontendScheme = "http";
    frontendHostname = "vikunja.${domain}";

    database.path = "/data/vikunja.db";

    environmentFiles = ["/secrets/env"];

    settings = {
      timezone = config.time.timeZone;
      enaleuserdeletion = false;

      service.enableregistration = false;

      mailer = {
        enabled = true;
	host = "mail.${domain}";
	port = 465;
	username = "vikunja";
	# password set in VIKUNJA_MAILER_PASSWORD env
	fromemail = "vikunja@${domain}";
	forcessl = true;
      };

      files = {
        basepath = mkForce "/data/files";
	maxsize = "100MB";
      };
    };
  };
}
