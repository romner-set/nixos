{
  lib,
  pkgs,
  ...
}: {
  #environment.systemPackages = with pkgs; [jellyfin-web];
  services.jellyfin.enable = true;
}
