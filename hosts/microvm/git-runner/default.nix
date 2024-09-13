{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  inherit (config.networking) domain;
in {
  virtualisation.docker.enable = true;
  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.default = {
      enable = true;
      name = "default"; #TODO
      url = "https://git.${domain}";
      tokenFile = "/secrets/env";
      labels = [
        "ubuntu-latest:docker://node:16-bullseye"
        "ubuntu-22.04:docker://node:16-bullseye"
        "ubuntu-20.04:docker://node:16-bullseye"
        "ubuntu-18.04:docker://node:16-buster"     
        ## optionally provide native execution on the host:
        # "native:host"
      ];
    };
  };
}
