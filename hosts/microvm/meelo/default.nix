{
  lib,
  pkgs,
  ...
}:
with lib; let
  compose = ./docker-compose.yml;
in {
  cfg.microvm.services.watchtower.enable = true;

  #environment.etc."meelo/env".source = mkForce "/secrets/rendered/env"; # sops template defined in meta.nix
  #environment.etc."meelo/settings.json".source = mkForce "/secrets/rendered/settings.json"; # mounted as docker volume instead

  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [docker-compose];
  systemd.services.meelo = {
    script = ''
      docker-compose --env-file /secrets/rendered/env -f ${compose} up
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    path = [pkgs.docker-compose];
  };
}
