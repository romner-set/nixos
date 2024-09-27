{...}: {
  id = 22;

  webPorts = [80];

  locations."/" = {
    proto = "http";
    port = 80;
  };
  authPolicy = "bypass";
  #bypassAuthForLAN = true;

  shares = [
    {
      proto = "virtiofs";
      tag = "uptime-data";
      source = "/vm/uptime";
      mountPoint = "/data";
    }
  ];
}
