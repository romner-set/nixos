cfg: {
  id = 21;

  subdomain = "kiowl";
  webPorts = [80];

  locations."/" = {
    proto = "http";
    port = 80;
  };
  bypassAuthForLAN = true;

  shares = [
    {
      proto = "virtiofs";
      tag = "kitchenowl-data";
      source = "/vm/kitchenowl";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "kitchenowl-secrets";
      source = "/run/secrets/vm/kitchenowl";
      mountPoint = "/secrets";
    }
  ];

  secrets = {
    "vm/kitchenowl/env" = {};
    #"vm/netbox/mail_pass" = {}; #TODO
  };
}
