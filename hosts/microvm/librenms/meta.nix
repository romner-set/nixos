{...}: {
  id = 19;

  webPorts = [80];

  locations."/" = {
    proto = "http";
    port = 80;
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "librenms-data";
      source = "/vm/librenms/data";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "librenms-secrets";
      source = "/run/secrets/vm/librenms";
      mountPoint = "/secrets";
    }
  ];

  secrets = {
    "vm/librenms/dbpassword" = {};
  };
}
