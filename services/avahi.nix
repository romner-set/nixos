{
  config,
  configLib,
  lib,
  pkgs,
  sops,
  ...
}:
with lib; let
  cfg = config.svc.avahi;
in {
  options.svc.avahi.reflector = {
    enable = mkEnableOption "";
    interfaces = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.reflector.enable {
    services.avahi = {
      enable = true;

      allowInterfaces = cfg.reflector.interfaces;

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
