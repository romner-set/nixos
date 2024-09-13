cfg: {
  id = 13;

  tcpPorts = [25 465 993];
  webPorts = [80 81 82];
  #aliases = ["mta-sts" "autoconfig"]; #TODO: currently defined manually in ../nginx/default.nix

  locations."/" = {
    proto = "http";
    port = 82;
  };
  csp = "lax";

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
