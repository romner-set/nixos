{
  lib,
  pkgs,
  config,
  ...
}:
with lib; {
  services.nginx = {
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
        extraConfig = "autoindex on;";
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
        extraConfig = "autoindex on;";
      };
    };
  };
}
