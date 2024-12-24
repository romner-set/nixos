{
  lib,
  pkgs,
  ...
}: {
  #environment.systemPackages = with pkgs; [jellyfin-web];
  services.jellyfin = {
    enable = true;
    user = "vm-jellyfin";
    group = "vm-jellyfin";
  };
  systemd.services.jellyfin.serviceConfig.BindPaths = ["/media"];
}
