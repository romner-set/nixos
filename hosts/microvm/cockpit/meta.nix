cfg: {
  id = 12;
  vcpu = 2;
  mem = 512;

  #subdomain = "${hostname}";
  locations."/" = {
    proto = "http";
    port = 9090;
  };
  csp = "none";
}
