{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;
in {
  /*users.users.vikunja = {
    isSystemUser = true;
    shell = pkgs.fish;
    group = "vikunja";
  };
  users.groups.vikunja = {};*/

  systemd.services.vikunja.serviceConfig = {
    User = "root";
    DynamicUser = mkForce false;
    BindPaths = ["/data"];
  };

  environment.etc."vikunja/config.yaml".source = mkForce "/secrets/rendered/config.yaml"; # sops template defined in meta.nix

  services.vikunja = {
    enable = true;
    environmentFiles = ["/secrets/env"];

    frontendScheme = "http";
    frontendHostname = "vikunja.${domain}";
  };
}
