{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  compose = ./docker-compose.yml;
in {
  cfg.microvm.services.watchtower.enable = true;

  environment.etc."kitchenowl/env".text = ''
    OIDC_ISSUER=https://auth.${config.networking.domain}
    DISABLE_USERNAME_PASSWORD_LOGIN=true
    FRONT_URL=https://kitchenowl.${config.networking.domain}
  '';

  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [docker-compose];
  systemd.services.kitchenowl = {
    script = ''
      docker-compose --env-file /etc/kitchenowl/env --env-file /secrets/env -f ${compose} up
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    path = [pkgs.docker-compose];
  };
}
