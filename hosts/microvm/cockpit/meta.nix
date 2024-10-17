{...}: {
  id = 12;
  vcpu = 2;
  mem = 512;

  vHosts.cockpit = {
    locations."/" = {
      proto = "http";
      port = 9090;
    };
    csp = "none";
  };
}
