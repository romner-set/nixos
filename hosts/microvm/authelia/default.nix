{
  lib,
  pkgs,
  config,
  vmsEnabled,
  hostNetwork,
  vms,
  ...
}:
with lib; let
  inherit (hostNetwork) ipv4 ipv6;
  inherit (config.networking) domain;
in {
  config = {
    systemd.services.authelia-main.serviceConfig.BindPaths = ["/data" "/secrets"];

    /*
      users.users.authelia = {
      uid = 10000 + self.id;
      isSystemUser = true;
      group = "root";
    };
    */
    /*
      users.groups.authelia = {
      gid = 10000 + self.id;
    };
    */

    services.authelia.instances.main = {
      enable = true;
      user = "root";
      group = "root";
      secrets.storageEncryptionKeyFile = "/secrets/db_pass";
      secrets.jwtSecretFile = "/secrets/jwt_secret";
      environmentVariables = {
        "AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE" = "/secrets/mail_pass";
      };
      settings = {
        theme = "dark";
        default_redirection_url = "https://${domain}";
        default_2fa_method = "totp";

        server = {
          host = "0.0.0.0";
          port = 9091;
          path = "";
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
            path = "/data/users.yml";
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

        session = {
          domain = "${domain}";
          expiration = "1h";
          inactivity = "5m";
          remember_me_duration = "1M";
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

        storage = {local = {path = "/data/db.sqlite3";};};
        notifier = {
          disable_startup_check = true;
          smtp = {
            # TODO: host = "${ipv6.subnet.microvm}${vms.mail.ipv6}";
            host = "mail.${domain}";
            port = 465;
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
            [
              # global conf
              {
                domain = ["autoconfig.${domain}" "mta-sts.${domain}"]; #TODO: move this to mail's meta.nix
                policy = "bypass";
              }
              {
                domain = "srv.${domain}";
                resources = "^/private(/.*)?$";
                subject = "group:admin";
                policy = "two_factor";
              }
              {
                domain = ["${domain}" "srv.${domain}"];
                methods = ["GET" "HEAD"];
                policy = "bypass";
              }
            ]
            ++
            # vms
            (attrsets.mapAttrsToList (vmName: vmData: let
                authPolicy = attrsets.attrByPath ["authPolicy"] "two_factor" vmData;
                sub = attrsets.attrByPath ["subdomain"] vmName vmData;
              in {
                domain = "${sub}.${domain}";
                subject =
                  if authPolicy != "bypass"
                  then "group:admin"
                  else null;
                policy = authPolicy;
              })
              vmsEnabled);
          /*
             ++
          # vhosts
          (attrsets.mapAttrsToList (name: data: {
              domain =
                ["${attrsets.attrByPath ["serverName"] name data}.${domain}"]
                ++ (attrsets.attrByPath ["serverAliases"] [] data);
              subject = "group:admin";
              policy = "two_factor";
            })
            vHosts.sec)
          ++ (attrsets.mapAttrsToList (name: data: {
              domain =
                ["${attrsets.attrByPath ["serverName"] name data}.${domain}"]
                ++ (attrsets.attrByPath 8192 ["serverAliases"] [] data);
              policy = "bypass";
            })
            vHosts.pub)
          ++ config.env.additionalAutheliaRules;
          */
        };
      };
    };
  };
}
