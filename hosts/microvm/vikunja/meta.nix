cfg: {
  id = 20;

  webPorts = [3456];

  locations."/" = {
    proto = "http";
    port = 3456;
  };
  bypassAuthForLAN = true;

  shares = [
    {
      proto = "virtiofs";
      tag = "vikunja-data";
      source = "/vm/vikunja";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "vikunja-secrets";
      source = "/run/secrets/vm/vikunja";
      mountPoint = "/secrets";
    }
  ];

  secrets = {
    "vm/vikunja/env" = {};
  };
}
