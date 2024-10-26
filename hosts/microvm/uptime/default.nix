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
      (lists.flatten (attrsets.mapAttrsToList (
          vmName: vmData: [
            # VM ping
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

            # web locations
            (attrsets.mapAttrsToList (
                vHostName: vHost: (attrsets.mapAttrsToList (path: lData: {
                    name = "${vmName}-web-${vHostName}-${path}";
                    group = "${zeroPad 2 (toString vmData.id)} ${vmName}";
                    url = "${lData.proto}://[${ipv6.subnet.microvm}::${toString vmData.id}]:${toString lData.port}";

                    conditions = [
                      "[CONNECTED] == true"
                      "[STATUS] == any(200, 404)"
                      "[RESPONSE_TIME] < ${toString vHost.expectedMaxResponseTime}" # default 50
                    ];

                    client.insecure = vHost.useInternalCA;
                  })
                  vHost.locations)
              )
              vmData.vHosts)
          ]
        )
        (attrsets.filterAttrs (name: _: name != config.networking.hostName) vmsEnabled)))
      ++ [
        #TODO: move to nginx config, track stuff like DNS & SMB
        {
          name = "${domain}";
          url = "https://${domain}";
          group = "! core";

          conditions = [
            "[CONNECTED] == true"
            "[STATUS] == 200"
            "[RESPONSE_TIME] < 15"
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
