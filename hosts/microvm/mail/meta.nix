{...}: {
  id = 13;

  tcpPorts = [25 465 993];
  webPorts = [80 81 82];

  vHosts.mail = {
    locations."/".port = 82;
    csp = "lax";
  };
  vHosts."autoconfig" = {
    locations."/".port = 80;
    authPolicy = "bypass";
  };
  vHosts."mta-sts" = {
    locations."/".port = 81;
    authPolicy = "bypass";
  };

  shares = [
    {
      proto = "virtiofs";
      tag = "mail-data";
      source = "/vm/mail";
      mountPoint = "/data";
    }
    {
      proto = "virtiofs";
      tag = "mail-ssl";
      source = "/vm/nginx/ssl";
      mountPoint = "/ssl";
    }
  ];
}
