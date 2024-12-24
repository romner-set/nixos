{
  lib,
  pkgs,
  unstable,
  config,
  configLib,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  self = vms.${config.networking.hostName};
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;

  credsPath = "/run/credentials/authelia-main.service";
in {
  # use unstable service
  disabledModules = ["services/security/authelia.nix" "services/databases/redis.nix"];
  imports = ["${unstable.path}/nixos/modules/services/databases/redis.nix" "${unstable.path}/nixos/modules/services/security/authelia.nix"];

  config = {
    services.redis.servers.authelia = {
      enable = true;
      unixSocket = "/run/redis-authelia/redis.sock";
      user = "vm-authelia-redis";
      group = "vm-authelia";
      settings = {
        dir = mkForce "/data/redis";
      };
    };

    systemd.services.redis-authelia.serviceConfig.BindPaths = ["/data/redis"];

    systemd.services.authelia-main.serviceConfig = {
      BindPaths = ["/data/auth" "/run/redis-authelia/redis.sock"];
      LoadCredential = lists.flatten (
        (configLib.toCredential [
          "rendered/users.yml"
          "db_pass"
          "mail_pass"
          "jwt_secret"
          "session_secret"
          "oidc_hmac"
          "oidc_jwk"
        ])
        ++ (attrsets.mapAttrsToList (
          vmName: vm:
            configLib.toCredential (attrsets.mapAttrsToList (n: _: n)
              (attrsets.filterAttrs (n: v: strings.hasPrefix "oidc/" n) vm.secrets))
        ) (attrsets.filterAttrs (n: v: v.oidc.enable) vmsEnabled))
      );
    };

    services.authelia.instances.main = {
      enable = true;
      user = "vm-authelia";
      group = "vm-authelia";

      package = unstable.authelia;

      secrets = {
        storageEncryptionKeyFile = "${credsPath}/db_pass";
        jwtSecretFile = "${credsPath}/jwt_secret";
        sessionSecretFile = "${credsPath}/session_secret";

        oidcHmacSecretFile = "${credsPath}/oidc_hmac";
        oidcIssuerPrivateKeyFile = "${credsPath}/oidc_jwk";
      };

      environmentVariables = {
        "AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE" = "${credsPath}/mail_pass";
        "X_AUTHELIA_CONFIG_FILTERS" = "template"; # used for OIDC clients
      };
      settings = {
        theme = "dark";
        default_2fa_method = "totp";

        server = {
          address = "tcp://:9091/";
        };

        totp = {
          issuer = "${domain}";
          algorithm = "sha512";
          digits = 8;
          secret_size = 128;
        };

        webauthn = {display_name = "${domain}";};
        authentication_backend = {
          password_reset = {disable = true;};
          file = {
            path = "${credsPath}/rendered-users.yml";
            watch = false;
            password = {
              algorithm = "argon2";
              argon2 = {
                variant = "argon2id";
                iterations = 8;
                memory = 524288;
                parallelism = 4;
                key_length = 128;
                salt_length = 16;
              };
            };
          };
        };

        identity_providers.oidc = {
          #TODO: authorization_policies = {};
          clients = attrsets.mapAttrsToList (vmName: vmData: {
            client_name = vmName;
            client_id = "{{ secret \"${credsPath}/oidc-${vmName}-id\" }}";
            client_secret = "{{ secret \"${credsPath}/oidc-${vmName}-secret_hash\" }}";
            public = false;
            authorization_policy = "two_factor";
            redirect_uris = vmData.oidc.redirectUris;
            scopes = vmData.oidc.scopes;
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = vmData.oidc.authMethod;
            pre_configured_consent_duration = "1w";
          }) (attrsets.filterAttrs (n: v: v.oidc.enable) vmsEnabled);
        };

        session = {
          expiration = "1h";
          inactivity = "5m";
          remember_me = "1M";

          redis.host = "/run/redis-authelia/redis.sock";

          cookies = [
            {
              inherit domain;
              authelia_url = "https://auth.${domain}";
              default_redirection_url = "https://${domain}";
            }
          ];
        };

        regulation = {
          max_retries = 10;
          find_time = "1m";
          ban_time = "1m";
        };
        password_policy = {
          zxcvbn = {
            enabled = true;
            min_score = 4;
          };
        };

        storage = {local = {path = "/data/auth/db.sqlite3";};};
        notifier = {
          disable_startup_check = true;
          smtp = {
            address = "smtp://mail.${domain}:465";
            username = "auth@${domain}";
            sender = "Authelia <auth@${domain}>";
            identifier = "auth@${domain}";
            startup_check_address = "admin@${domain}";
            tls = {server_name = "mail.${domain}";};
          };
        };

        ntp = {
          address = "time.nist.gov:123";
          disable_failure = true;
        };

        access_control = {
          default_policy = "deny";
          rules =
            builtins.filter (v: attrsets.hasAttrByPath ["domain"] v)
            (lists.flatten [
              # global conf
              {
                inherit domain;
                methods = ["GET" "HEAD"];
                policy = "bypass";
              }

              # vHosts w/ bypassAuthForLAN
              (attrsets.mapAttrsToList (
                  vmName: vmData: (attrsets.concatMapAttrs (vHostName: vHost: {
                      domain = "${vHostName}.${domain}";
                      networks = ipv4.trustedNetworks ++ ipv6.trustedNetworks;
                      policy = "bypass";
                    })
                    (attrsets.filterAttrs (n: v: v.bypassAuthForLAN) vmData.vHosts))
                )
                vmsEnabled)

              # vHosts
              (attrsets.mapAttrsToList (
                  vmName: vmData: (attrsets.mapAttrsToList (vHostName: vHost: let
                      inherit (vHost) authPolicy;
                    in {
                      domain = "${vHostName}.${domain}";
                      subject =
                        if authPolicy != "bypass"
                        then "group:admin"
                        else null;
                      policy = authPolicy;
                    })
                    vmData.vHosts)
                )
                vmsEnabled)
            ]);
        };
      };
    };
  };
}
