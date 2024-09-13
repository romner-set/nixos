{
  lib,
  pkgs,
  unstable,
  config,
  ...
}:
with lib; {
  /*
     nixpkgs.overlays = [
     (final: prev: {
       searxng = prev.searxng.overrideAttrs (old: {
         postInstall = (old.postInstall or "") + ''
    cp ${./searxng.png} $out/${pkgs.python3.sitePackages}/searx/static/themes/simple/img/searxng.png
  '';
       });
     })
   ];
  */
  services.searx = {
    #package = patchedSearxng;
    enable = true;
    redisCreateLocally = true;
    environmentFile = "/secrets/env";
    settings = {
      use_default_settings = true;
      server = {
        secret_key = "@SEARX_SECRET_KEY@"; # env var
        limiter = true;
        public_instance = true;
        image_proxy = true;
      };
      ui = {static_use_hash = true;};
      outgoing = {
        request_timeout = 5;
        max_request_timeout = 15;
        pool_connections = 1000000;
        pool_maxsize = 100000;
      };
    };
    limiterSettings.botdetection.ip_limit.link_token = true;
    runInUwsgi = true;
    uwsgiConfig = {
      disable-logging = true;
      http = "[::]:8080";
      chmod-socket = "660";
    };
  };
}
