{
  lib,
  pkgs,
  ...
}: {
  networking.useDHCP = true; #lib.mkDefault true;
  /*
    networking = {
    interfaces.enp1s0.ipv4.addresses = [
      {
        address = "10.47.0.101";
        prefixLength = 24;
      }
    ];
    interfaces.enp2s0.ipv4.addresses = [
      {
        address = "192.168.122.101";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "10.47.0.1";
      interface = "enp1s0";
    };
  };

  networking.resolvconf.enable = lib.mkForce false;
  environment.etc."resolv.conf".text = ''
    nameserver 10.47.0.2
    options edns0 trust-ad
  '';
  */
}
