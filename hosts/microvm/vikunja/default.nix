{
  lib,
  pkgs,
  config,
  configLib,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;
in {
  systemd.services.vikunja.serviceConfig = {
    User = "vm-vikunja";
    Group = "vm-vikunja";
    DynamicUser = mkForce false;
    BindPaths = ["/data"];
    LoadCredential = configLib.toCredential [ "rendered/config.yaml" ]; # sops template defined in meta.nix
  };

  environment.etc."vikunja/config.yaml".source = mkForce "/run/credentials/vikunja.service/rendered-config.yaml";
  #environment.etc."vikunja/config.yaml".source = mkForce "/secrets/rendered/config.yaml"; # sops template defined in meta.nix

  services.vikunja = {
    enable = true;
    environmentFiles = ["/secrets/rendered/env"];

    frontendScheme = "http";
    frontendHostname = "vikunja.${domain}";
  };
}
