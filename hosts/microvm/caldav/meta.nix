{...}: {
  id = 11;
  webPorts = [80];

  vHosts.dav = {
    locations."/" = {
      proto = "http";
      port = 80;
    };
    #authPolicy = "bypass";
    bypassAuthForLAN = true;
    expectedMaxResponseTime = 100; # avg 49-62
  };

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
