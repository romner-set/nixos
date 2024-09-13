{
  lib,
  pkgs,
  unstable,
  config,
  ...
}:
with lib; {
  #environment.systemPackages = [pkgs.mox];
  users.users.mox = {
    isSystemUser = true;
    shell = pkgs.fish;
    home = "/data";
    group = "mox";
  };
  users.groups.mox = {};

  systemd.services.mox = {
    enable = true;
    serviceConfig.WorkingDirectory = "/data";
    script = "./mox serve";
    wantedBy = ["multi-user.target"];
  };
}
