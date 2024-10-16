{
  config,
  lib,
  pkgs,
  domain,
  ...
}:
with lib; let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
in {
  services.nginx.enable = true;
  services.nginx.virtualHosts.${fqdn} = {
    listen = [
      {
        addr = "[::]";
        port = 80;
      }
    ];
    root = pkgs.element-web.override {
      # See https://github.com/element-hq/element-web/blob/develop/config.sample.json
      conf = {
        default_theme = "dark";

        #default_server_name = domain;
        default_server_config = {
        };

        #disable_guests = true;
        disable_custom_urls = true;

        /*
        features = {
               feature_oidc_native_flow = true;
         	};
        */
      };
    };
  };
}
