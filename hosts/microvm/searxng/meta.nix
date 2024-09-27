{...}: {
  id = 3;
  webPorts = [8080];

  subdomain = "search";
  locations."/" = {
    proto = "http";
    port = 8080;
  };
  authPolicy = "bypass";
  expectedMaxResponseTime = 60; # 50-55 avg

  shares = [
    {
      proto = "virtiofs";
      tag = "searxng-secrets";
      source = "/run/secrets/vm/searxng";
      mountPoint = "/secrets";
    }
  ];

  secrets = {
    "vm/searxng/env" = {};
  };
}
