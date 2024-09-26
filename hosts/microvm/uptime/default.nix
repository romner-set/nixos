{
  lib,
  pkgs,
  config,
  configLib,
  ...
}:
with lib; let
  inherit (config.cfg.microvm.host) net vms vmsEnabled;
  inherit (net) ipv4 ipv6;
  inherit (config.networking) domain;
  inherit (configLib.strings) zeroPad;
in {
  environment.etc."gatus/config.yml".source = (pkgs.formats.yaml {}).generate "gatus-config.yml" {
    storage = {
      type = "sqlite";
      path = "/data/gatus.db";
      caching = true;
    };

    web.address = "[::]";
    web.port = 80;

    endpoints =
      (lists.concatLists (attrsets.mapAttrsToList (vmName: vmData:
        lists.concatLists [
          # VM ping
          [
            {
              name = "${vmName}-icmp";
              group = "${zeroPad 2 (toString vmData.id)} ${vmName}";
              url = "icmp://${ipv6.subnet.microvm}::${toString vmData.id}";
              ui.hide-hostname = true;

              conditions = [
                "[CONNECTED] == true"
                "[RESPONSE_TIME] < 1" # internal comms between VMs
              ];
            }
          ]

          # web locations
          (attrsets.mapAttrsToList (path: lData: {
              name = "${vmName}-web-${path}";
              group = "${zeroPad 2 (toString vmData.id)} ${vmName}";
              url = "${lData.proto}://[${ipv6.subnet.microvm}::${toString vmData.id}]:${toString lData.port}";

              conditions = [
                "[CONNECTED] == true"
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${toString vmData.expectedMaxResponseTime}" # default 10; koel takes like 250ms, but most services are ~1ms
              ];
            })
            vmData.locations)
        ])
      (attrsets.filterAttrs (name: _: name != config.networking.hostName) vmsEnabled)))
      ++ [
        #TODO: move to microvm configs, track stuff like DNS & SMB
        {
          name = "${domain}";
          url = "https://${domain}";
          group = "! core";

          conditions = [
            "[CONNECTED] == true"
            "[STATUS] == 200"
            "[RESPONSE_TIME] < ${toString vms.nginx.expectedMaxResponseTime}"
          ];
        }
      ];
  };

  systemd.services.gatus = {
    enable = true;
    environment.GATUS_CONFIG_PATH = "/etc/gatus";
    script = "${pkgs.gatus}/bin/gatus";
    wantedBy = ["multi-user.target"];
  };
}
