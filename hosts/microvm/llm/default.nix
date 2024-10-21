{
  lib,
  pkgs,
  unstable,
  ...
}:
with lib; let
  compose = ./docker-compose.yml;
in {
  cfg.microvm.services.watchtower.enable = true;

  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    docker-compose
    #unstable.oterm
    oterm
  ];
  systemd.services.open-webui = {
    script = ''
      docker-compose -f ${compose} up
    '';
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    path = [pkgs.docker-compose];
  };

  services.ollama = {
    package = unstable.ollama;
    enable = true;
    #acceleration = "rocm"; # note: takes *forever* to compile
    listenAddress = "0.0.0.0:11434";
    models = "/models";
    home = "/ollama";
    writablePaths = ["/models" "/ollama"];
  };

  /*
    microvm.devices = [
    {
      bus = "pci";
      path = "0000:10:00.0";
    }
    {
      bus = "pci";
      path = "0000:10:00.1";
    }
  ];#
  */
}
