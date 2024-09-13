cfg: {
  id = 11;
  webPorts = [80];

  subdomain = "dav";
  locations."/" = {
    proto = "http";
    port = 80;
  };
  authPolicy = "bypass";

  shares = [
    {
      proto = "virtiofs";
      tag = "caldav-secrets";
      source = "/run/secrets/vm/caldav";
      mountPoint = "/secrets";
    }
    {
      proto = "virtiofs";
      tag = "caldav-data";
      source = "/vm/caldav";
      mountPoint = "/data";
    }
  ];

  secrets = {
    "vm/caldav/passwd" = {};
    "vm/caldav/appsecret" = {};
  };
}
