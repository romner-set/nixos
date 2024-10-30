{
  lib,
  pkgs,
  config,
  ...
}:
with lib; {
  services.nginx = let
    extraConfig = ''
      autoindex on;

      proxy_max_temp_file_size 0;

      sendfile           on;
      sendfile_max_chunk 1m;

      tcp_nopush on;
      tcp_nodelay       on;
      keepalive_timeout 65;
    '';
  in {
    enable = true;
    enableReload = true;

    recommendedOptimisation = true;

    virtualHosts."public" = {
      serverName = "_";
      default = true;
      listen = [
        {
          addr = "[::]";
          port = 80;
        }
      ];
      locations."/" = {
        root = "/srv/public";
        inherit extraConfig;
      };
    };

    virtualHosts."private" = {
      serverName = "_";
      default = true;
      listen = [
        {
          addr = "[::]";
          port = 81;
        }
      ];
      locations."/" = {
        root = "/srv/private";
        inherit extraConfig;
      };
    };
  };
}
