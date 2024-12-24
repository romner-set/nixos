{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  environment.systemPackages = with pkgs; [nodejs];

  systemd.services.fvtt = {
    enable = true;
    script = ''
      cd /data/fvtt
      ${pkgs.nodejs}/bin/node resources/app/main.js --dataPath=/data/data
    '';
    wantedBy = ["multi-user.target"];
    after = [];
    path = ["/data"];
  };
}
