{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [rathole];

  systemd.services.rathole-1 = {
    description = "rathole service";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.rathole}/bin/rathole /secrets/rathole-1.toml";
      Restart = "on-failure";
    };
    wantedBy = ["default.target"];
  };

  systemd.services.rathole-2 = {
    description = "rathole service";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.rathole}/bin/rathole /secrets/rathole-2.toml";
      Restart = "on-failure";
    };
    wantedBy = ["default.target"];
  };
}
