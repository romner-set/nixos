{config, ...}: {
  id = 3;
  webPorts = [8080];

  vHosts.search = {
    locations."/" = {
      proto = "http";
      port = 8080;
    };
    authPolicy = "bypass";
    expectedMaxResponseTime = 60; # 50-55 avg
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "searxng-secrets";
      source = "/run/secrets/rendered/vm/searxng";
      mountPoint = "/secrets/rendered";
    }
  ];

  secrets = {
    "vm/searxng/key" = {};
  };

  templates."vm/searxng/env".content = ''
    SEARX_SECRET_KEY=${config.sops.placeholder."vm/searxng/key"}
  '';
}
