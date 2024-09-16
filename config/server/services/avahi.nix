{
  config,
  configLib,
  lib,
  pkgs,
  sops,
  ...
}:
with lib; let
  cfg = config.cfg.server.services.avahi.reflector;
in {
  options.cfg.server.services.avahi.reflector = {
    enable = mkEnableOption "";
    interfaces = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    services.avahi = {
      enable = true;

      allowInterfaces = cfg.interfaces;

      wideArea = false;
      openFirewall = false;

      nssmdns4 = true;
      reflector = true;
      publish = {
        domain = true;
        addresses = true;
      };
    };
  };
}
