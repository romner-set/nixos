{
  lib,
  pkgs,
  config,
  unstable,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;

  #snippetsDir = ./../../../common/nginx/global;
  #universalSnippets = concatStrings (map (n: builtins.readFile "${snippetsDir}/${n}") (builtins.attrNames (builtins.readDir snippetsDir)));

  extraSnippets = {
    necessary = ''
      # Custom headers
      add_header Cat '~(=^.^=)' always;
      add_header Contact admin@${domain} always;
      add_header X-Powered-By NixOS always;

      # Manual SSL
      http2 on;
      #ssl_certificate /ssl/${domain}/fullchain.pem;
      #ssl_certificate_key /ssl/${domain}/key.pem;
      #ssl_trusted_certificate /ssl/${domain}/chain.pem;
      ssl_conf_command Options KTLS;
      #ssl_session_cache shared:SSLCACHE:50m;
      #ssl_session_timeout 5m;
      ssl_session_tickets on;
      add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload" always;

      # Quic
      http3 on;
      http3_hq on;
      quic_retry on;
      add_header Alt-Svc 'h3=":443"; ma=86400' always;
      add_header Quic-Status $http3 always;
      add_header X-Quic 'h3' always;
      listen 443 quic;
      listen [::]:443 quic;
    '';

    cors = ''
      #add_header Access-Control-Allow-Origin 'https://auth.${domain}' always;
      add_header 'Access-Control-Allow-Origin' '*' always;

      # TODO: https://enable-cors.org/server_nginx.html
    '';

    secHeaders = ''
      # Security headers
      #add_header X-Content-Type-Options "nosniff" always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header Referrer-Policy 'same-origin' always;
    '';

    authelia =
      ''
        # Authelia location
        set $upstream_authelia http://[${ipv6.subnet.microvm}::${toString vms.authelia.id}]:9091/api/authz/auth-request;

        location @authelia-redirect {
        	return 302 https://auth.${domain}/?rd=$scheme://$host$request_uri;
        }
      ''
      + (builtins.readFile ./authelia/location.conf);

    robotsTxt = ''
      add_header X-Robots-Tag 'none' always;
      location = /robots.txt { return 200 "User-agent: *\nDisallow: /\n"; }
    '';
  };

  certConfig = conf: let
    prefix = conf.prefix or "";
  in {
    sslCertificate = "/ssl/${prefix}${domain}/fullchain.pem";
    sslCertificateKey = "/ssl/${prefix}${domain}/key.pem";
    sslTrustedCertificate = "/ssl/${prefix}${domain}/chain.pem";
  };

  virtualHostsCommonConfig =
    {
      http3_hq = true;
      #quic = true;

      extraConfig = with extraSnippets;
        concatStrings [
          necessary
          secHeaders
          cors
          authelia
          robotsTxt
        ];

      kTLS = true;
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
        {
          addr = "[::]";
          port = 443;
          ssl = true;
        }
      ];
    }
    // (certConfig {});

  csp = {
    lax = "upgrade-insecure-requests; default-src 'self' data: blob:; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; frame-ancestors 'self';";
    strict = "upgrade-insecure-requests; default-src 'none'; manifest-src 'self' https://auth.${domain}; script-src 'self'; style-src 'self'; form-action 'self'; font-src 'self'; frame-ancestors 'self'; base-uri 'self'; connect-src 'self'; img-src 'self' data: blob:; frame-src 'none'; media-src 'self'; require-trusted-types-for 'script';";
    none = "";
  };

  permissionsPolicy = policies:
    strings.concatStringsSep ", " (attrsets.mapAttrsToList (policyName: policy: "${policyName}=(${strings.concatStringsSep " " policy})") ({
        accelerometer = [];
        ambient-light-sensor = [];
        autoplay = ["self"];
        battery = [];
        camera = [];
        cross-origin-isolated = [];
        display-capture = [];
        document-domain = [];
        encrypted-media = [];
        execution-while-not-rendered = [];
        execution-while-out-of-viewport = [];
        fullscreen = ["self"];
        geolocation = [];
        gyroscope = [];
        keyboard-map = [];
        magnetometer = [];
        microphone = [];
        midi = [];
        navigation-override = [];
        payment = [];
        picture-in-picture = [];
        publickey-credentials-get = [];
        screen-wake-lock = [];
        sync-xhr = [];
        usb = [];
        web-share = [];
        xr-spatial-tracking = [];
        clipboard-read = [];
        clipboard-write = ["self"];
        gamepad = [];
        speaker-selection = [];
        conversion-measurement = [];
        focus-without-user-activation = [];
        hid = [];
        idle-detection = [];
        interest-cohort = [];
        serial = [];
        sync-script = [];
        trust-token-redemption = [];
        unload = [];
        window-placement = [];
        vertical-scroll = [];
      }
      // policies));

  limitedLocation = ''
    limit_except GET HEAD OPTIONS {
      deny all;
    }
  '';

  autheliaProxyConfig = concatStrings [
    (builtins.readFile ./authelia/authrequest.conf)
    (builtins.readFile ./authelia/proxy.conf)
    ''
      proxy_hide_header Access-Control-Allow-Origin;
      proxy_hide_header Access-Control-Allow-Credentials;
    ''
  ];
in {
  imports = [./acme.nix];
  config = {
    users.users.nginx.uid = 60;
    users.groups.nginx.gid = 60;
    environment.systemPackages = with pkgs; [curlHTTP3];
    services.nginx = {
      #logError = "stderr debug";
      enable = true;
      package = pkgs.nginxQuic;
      enableReload = true;

      additionalModules = [
        #pkgs.nginxModules.njs
      ];

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      #recommendedProxySettings = true;
      recommendedTlsSettings = true;

      appendHttpConfig = ''
        ssl_early_data on;
        ssl_ecdh_curve X25519; #:prime256v1:secp384r1:secp521r1;
      '';

      enableQuicBPF = true;

      sslProtocols = "TLSv1.3";
      sslCiphers = "AES128-GCM-SHA256:AES256-GCM-SHA384:CHACHA20-POLY1305-SHA256";

      #sslDhparam = "";

      virtualHosts = mapAttrs (_: vHost:
        attrsets.mergeAttrsList [
          virtualHostsCommonConfig
          vHost
        ]) (attrsets.mergeAttrsList [
        {
          "default" = {
            forceSSL = true;
            serverName = "_";
            default = true;
            globalRedirect = domain;
            listen = [
              {
                addr = "0.0.0.0";
                port = 443;
                ssl = true;
              }
              {
                addr = "[::]";
                port = 443;
                ssl = true;
              }
              {
                addr = "0.0.0.0";
                port = 80;
              }
              {
                addr = "[::]";
                port = 80;
              }
            ];
            quic = false;
            extraConfig = ''
              ssl_session_tickets on;

              # Custom headers
              add_header Cat '~(=^.^=)' always;
              add_header Contact admin@${domain} always;
              add_header X-Powered-By NixOS always;

              # Quic
              http3 on;
              http3_hq on;
              quic_retry on;
              add_header Alt-Svc 'h3=":443"; ma=86400' always;
              add_header Quic-Status $http3 always;
              add_header X-Quic 'h3' always;
              listen 443 quic default_server reuseport;
              listen [::]:443 quic default_server reuseport;
            '';
          };

          "${domain}" = {
            locations."@redirect" = {
              return = "302 $scheme://$host";
              extraConfig = limitedLocation;
            };
            locations."/" = {
              #return = "200 '${builtins.readFile ./srv/index.html}'";
              root = ./srv/cynosure.red;
              index = "index.html";
              extraConfig = concatStrings [
                ''
                  error_page 404 = @redirect;
                  error_page 500 = @redirect;
                ''
                limitedLocation
              ];
            };

            ## matrix
            locations."= /.well-known/matrix/server" = {
              return = "200 '{\"m.server\": \"matrix-federation.${domain}:443\"}'";
              extraConfig = limitedLocation;
            };
            locations."= /.well-known/matrix/client" = {
              return = "200 '${builtins.toJSON {
                "m.homeserver".base_url = "https://matrix-client.${domain}";
                #"m.identity_server".base_url = "https://vector.im";
                "org.matrix.msc3575.proxy".url = "https://matrix-slidingsync.${domain}";
              }}'";
              extraConfig = limitedLocation;
            };

            extraConfig = with extraSnippets;
              concatStrings [
                virtualHostsCommonConfig.extraConfig
                ''
                  add_header Content-Security-Policy "${csp.lax}" always;
                  add_header Permissions-Policy '${permissionsPolicy {}}' always;
                ''
              ];
          };
        }

        # vhosts
        (attrsets.concatMapAttrs (
          vmName: vmData: (
            mapAttrs' (vHostName: vHost:
              nameValuePair "${vHostName}.${domain}" ({
                  locations =
                    mapAttrs (_: lData: {
                      proxyPass = "${lData.proto}://[${ipv6.subnet.microvm}::${toString vmData.id}]:${toString lData.port}";
                      extraConfig =
                        if vmName != "authelia"
                        then autheliaProxyConfig
                        else (builtins.readFile ./authelia/proxy.conf);
                    })
                    vHost.locations;
                  extraConfig = concatStrings [
                    virtualHostsCommonConfig.extraConfig
                    ''
                      add_header Content-Security-Policy "${csp.${vHost.csp}}" always;
                      add_header Permissions-Policy '${permissionsPolicy vHost.permissionsPolicy}' always;
                      client_max_body_size ${vHost.maxUploadSize};
                    ''
                  ];
                }
                // (certConfig {
                  prefix =
                    if vHost.useInternalCA
                    then "internal-"
                    else "";
                })))
            (attrsets.filterAttrs (n: v: v.locations != {}) vmData.vHosts)
          )
        ) (attrsets.filterAttrs (n: v: v.vHosts != {}) vmsEnabled))
      ]);
    };
  };
}
