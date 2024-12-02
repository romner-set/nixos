{config, ...}: {
  id = 19;

  webPorts = [80];

  vHosts.librenms = {
    locations."/" = {
      proto = "http";
      port = 80;
    };
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
      source = "/run/secrets/rendered/vm/librenms";
      mountPoint = "/secrets/rendered";
    }
  ];

  secrets = {
    "vm/librenms/dbpassword" = {};
  };

  templates."vm/librenms/env".content = ''
    DB_PASSWORD=${config.sops.placeholder."vm/librenms/dbpassword"}
  '';
}
