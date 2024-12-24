{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
with lib; {
  svc.watchtower.enable = true;
  svc.docker.open-webui = {
    enable = true;
    compose = ./docker-compose.yml;
  };

  environment.systemPackages = with pkgs; [
    #unstable.oterm
    oterm
  ];

  services.ollama = {
    package = unstable.ollama;
    enable = true;
    #acceleration = "rocm"; # note: takes *forever* to compile
    port = 11434;
    host = "0.0.0.0";
    models = "/models";
    home = "/ollama";
  };
  systemd.services.ollama.serviceConfig.ReadWritePaths = ["/models" "/ollama"];

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
