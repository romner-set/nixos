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
      source = "/run/secrets/rendered/vm/kitchenowl";
      mountPoint = "/secrets/rendered";
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
    "vm/kitchenowl/jwt_secret" = {};
    "oidc/kitchenowl/id" = {};
    "oidc/kitchenowl/secret" = {};
    "oidc/kitchenowl/secret_hash" = {};
  };

  templates."vm/kitchenowl/env".content = ''
    OIDC_CLIENT_ID=${config.sops.placeholder."oidc/kitchenowl/id"}
    OIDC_CLIENT_SECRET=${config.sops.placeholder."oidc/kitchenowl/secret"}
    OIDC_ISSUER=https://auth.${config.networking.domain}
    DISABLE_USERNAME_PASSWORD_LOGIN=true

    JWT_SECRET_KEY=${config.sops.placeholder."vm/kitchenowl/jwt_secret"}
    FRONT_URL=https://kitchenowl.${config.networking.domain}
  '';
}
