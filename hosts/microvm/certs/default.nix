{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;
in {
  environment.systemPackages = with pkgs; [
    step-cli
  ];

  # override module settings
  environment.etc."smallstep/ca.json".source = mkForce "/secrets/rendered/ca.json";
  systemd.services."step-ca".serviceConfig = {
    # access to settings
    User = mkForce "root";
    Group = mkForce "root";
    ReadWritePaths = mkForce [];
    # force use of the local source-of-truth DNS resolver
    ExecStart = mkForce [
      "" # override upstream
      "${pkgs.step-ca}/bin/step-ca /etc/smallstep/ca.json --password-file \${CREDENTIALS_DIRECTORY}/intermediate_password --resolver [${ipv6.subnet.microvm}::${toString vms.nameserver.id}]:53"
    ];
  };

  services.step-ca = {
    enable = true;
    intermediatePasswordFile = "/secrets/intermediate_password";
    # dummy values, overriden above
    settings = {};
    address = "";
    port = 0;
  };
}
