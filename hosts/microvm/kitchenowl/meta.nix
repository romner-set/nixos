{config, ...}: let
  inherit (config.networking) domain;
in {
  id = 21;

  webPorts = [80];

  vHosts.kitchenowl = {
    locations."/" = {
      proto = "http";
      port = 80;
    };
    bypassAuthForLAN = true;
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "kitchenowl-data";
      source = "/vm/kitchenowl/data";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "kitchenowl-secrets";
      source = "/run/secrets/vm/kitchenowl";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "kitchenowl-docker";
      source = "/vm/kitchenowl/docker";
      mountPoint = "/var/lib/docker";
    }
  ];

  oidc.enable = true;
  oidc.redirectUris = [
    "kitchenowl:///signin/redirect"
    "https://kitchenowl.${domain}/signin/redirect"
  ];
  oidc.authMethod = "client_secret_post";

  secrets = {
    "vm/kitchenowl/env" = {};
    "oidc/kitchenowl/id" = {};
    "oidc/kitchenowl/secret" = {};
    "oidc/kitchenowl/secret_hash" = {};
  };
}
