{config, ...}: let
  cfg = config.cfg.server.microvm;
in {
  id = 8;

  webPorts = [8080];
  vcpu = cfg.defaults.vcpu.max;
  mem = 32768;

  locations."/" = {
    proto = "http";
    port = 8080;
  };
  csp = "lax";

  shares = [
    {
      proto = "virtiofs";
      tag = "llm-models";
      source = "/vm/llm/models";
      mountPoint = "/models";
    }
    {
      proto = "virtiofs";
      tag = "llm-ollama";
      source = "/vm/llm/ollama";
      mountPoint = "/ollama";
    }
    {
      proto = "virtiofs";
      tag = "llm-webui";
      source = "/vm/llm/webui";
      mountPoint = "/webui";
    }
    {
      proto = "virtiofs";
      tag = "llm-docker";
      source = "/vm/llm/docker";
      mountPoint = "/var/lib/docker";
    }
  ];
}
