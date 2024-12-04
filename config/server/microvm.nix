{
  config,
  configLib,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
} @ args:
with lib; let
  cfg = config.cfg.server.microvm;
  vmsEnabled = filterAttrs (_: vm: vm.enable) cfg.vms;
in {
  options.cfg.server.microvm = {
    enable = mkEnableOption "";
    autoUpdate = mkOption {
      type = types.bool;
      default = true;
    };

    defaults = {
      # set depending on processing power of host
      ## balanced around 8 phys. cores w/SMT
      vcpu = {
        low = mkOption {
          type = types.ints.positive;
          default = 2;
        };
        mid = mkOption {
          type = types.ints.positive;
          default = 4;
        };
        max = mkOption {
          type = types.ints.positive;
          default = 16;
        };
      };
      ## balanced around 16GB+ of RAM
      mem = {
        low = mkOption {
          type = types.ints.positive;
          default = 512;
        };
        mid = mkOption {
          type = types.ints.positive;
          default = 1024;
        };
        high = mkOption {
          type = types.ints.positive;
          default = 4096;
        };
      };

      hypervisor = mkOption {
        type = types.str;
        default = "qemu";
        #default = "cloud-hypervisor";
      };
    };

    vmConf = {
      # global config
      sshKeys = mkOption {
        type = types.listOf types.singleLineStr;
        default = [];
      };
    };

    vms = mkOption {
      type = with types;
        attrsOf (submodule ({name, ...}: {
          options = {
            enable = mkEnableOption "";
            name = mkOption {
              type = types.str;
              default = name;
            };

            id = mkOption {type = types.ints.positive;};

            vcpu = mkOption {
              type = types.ints.positive;
              default = cfg.defaults.vcpu.mid;
            };
            mem = mkOption {
              type = types.ints.positive;
              default = cfg.defaults.mem.mid;
            };

            hypervisor = mkOption {
              type = types.str;
              default = cfg.defaults.hypervisor;
            };

            shares = mkOption {
              type = types.listOf types.attrs;
              default = [];
            };

            users = mkOption {
              type = types.listOf types.str;
              default = [ name ];
            };

            ## sops-nix
            secrets = mkOption {
              type = types.attrs;
              default = {};
            };

            templates = mkOption {
              type = types.attrs;
              default = {};
            };

            ## vm-specific config, e.g. syncthing devices
            config = mkOption {
              type = types.attrs;
              default = {};
            };

            ## firewall
            webPorts = mkOption {
              type = types.listOf types.port;
              default = [];
            };
            webPortsUDP = mkOption {
              # only really used for nameserver
              type = types.listOf types.port;
              default = [];
            };

            tcpPorts = mkOption {
              type = types.listOf types.port;
              default = [];
            };
            udpPorts = mkOption {
              type = types.listOf types.port;
              default = [];
            };

            ## vm-dependent

            ### authelia
            oidc = {
              enable = mkEnableOption "";
              redirectUris = mkOption {type = types.listOf types.str;};
              scopes = mkOption {
                type = types.listOf types.str;
                default = ["openid" "profile" "email"];
              };
              authMethod = mkOption {
                type = types.str;
                default = "client_secret_basic";
              };
            };

            ### general web location
            vHosts = mkOption {
              type = attrsOf (submodule ({name, ...}: {
                options = {
                  name = mkOption {
                    type = types.str;
                    default = name;
                  };

                  ### uptime
                  expectedMaxResponseTime = mkOption {
                    type = types.ints.positive;
                    default = 50;
                  };

                  ### authelia
                  authPolicy = mkOption {
                    type = types.str;
                    default = "two_factor";
                  };
                  bypassAuthForLAN = mkOption {
                    type = types.bool;
                    default = false;
                  };

                  ### nginx
                  useInternalCA = mkOption {
                    type = types.bool;
                    default = false;
                  };

                  requireMTLS = mkOption {
                    type = types.bool;
                    default = false;
                  };

                  csp = mkOption {
                    type = types.str;
                    default = "lax";
                  };

                  permissionsPolicy = mkOption {
                    type = types.attrsOf (types.listOf types.str);
                    default = {};
                  };

                  maxUploadSize = mkOption {
                    type = types.str;
                    default = "10m";
                  };

                  aliases = mkOption {
                    type = types.listOf types.str;
                    default = [];
                  };

                  locations = mkOption {
                    type = attrsOf (submodule ({name, ...}: {
                      options = {
                        name = mkOption {
                          type = types.str;
                          default = name;
                        };

                        proto = mkOption {
                          type = types.str;
                          default = "http";
                        };
                        port = mkOption {
                          type = types.port;
                          default = 80;
                        };
                      };
                    }));
                    default = {};
                  };
                };
              }));
              default = {};
            };
          };
        }));
      default = {};
    };
  };

  config = {
    systemd.services."microvm-tap-interfaces@".serviceConfig.ExecStop = let
      stopScript = pkgs.writeShellScript "stop-microvm-tap-interfaces" ''
	cd /var/lib/microvms/$1
	for id in $(cat current/share/microvm/tap-interfaces); do
		${pkgs.iproute2}/bin/ip link del $id
	done
      '';
      in mkForce "${stopScript} %i";

    # VM metadata - always defined
    cfg.server.microvm.vms = listToAttrs (map (name: {
        inherit name;
        value = import (configLib.relativeToRoot "./hosts/microvm/${name}/meta.nix") args;
      })
      (builtins.attrNames (builtins.readDir (configLib.relativeToRoot "./hosts/microvm"))));

    # if cfg.enable
    ## cron
    services.cron.systemCronJobs = builtins.concatLists (lists.optionals cfg.enable [
      (lists.optional cfg.autoUpdate "0 3 * * *    root    /run/current-system/sw/bin/git -C /etc/nixos pull && /etc/nixos/utils/microvm-update-fast")
    ]);

    # users
    users.users = mkIf cfg.enable ((attrsets.concatMapAttrs (vmName: vm:
        builtins.listToAttrs (lists.imap0 (i: name: {
            name = "vm-${name}";
            value = rec {
              uid = 100000 + vm.id * 100 + i;
              isSystemUser = true;
              group = "vm-${vmName}";
            };
          })
          vm.users))
      (attrsets.filterAttrs (_: vm: vm.users != []) vmsEnabled))
      // {
        microvm.extraGroups = lib.mkForce ["keys"]; # allow access to sops keys
      });
    users.groups = mkIf cfg.enable (attrsets.mapAttrs' (vmName: vm: {
        name = "vm-${vmName}";
        value.gid = 100000 + vm.id * 100;
      })
      (attrsets.filterAttrs (_: vm: vm.users != []) vmsEnabled));

    ## sops-nix
    sops.secrets =
      mkIf
      cfg.enable (attrsets.concatMapAttrs (vmName: vm: (
          builtins.mapAttrs (_: secret:
            {
              sopsFile = "/secrets/${config.networking.hostName}/vm/${vmName}.yaml";
            }
            // secret)
          vm.secrets
        ))
        vmsEnabled); #TODO: change /secrets/ path
    sops.templates = mkIf cfg.enable (attrsets.concatMapAttrs (_: vm: vm.templates) vmsEnabled);
    systemd.services."microvm-virtiofsd@".serviceConfig.TimeoutStopSec = 1;

    ## actual microvm defs
    microvm = mkIf cfg.enable {
      host.enable = lib.mkForce true;

      #virtiofsd.extraArgs = ["--cache=never"];

      vms =
        mapAttrs' (name: vm: {
          name = "${config.networking.hostName}:${name}";
          value = rec {
            flake = inputs.self;
            updateFlake = "git+file:///etc/nixos";
            #restartIfChanged = true;
          };
        })
        vmsEnabled;
    };
  };

  /*
    config = mkIf cfg.enable (let
    vmsEnabled = filterAttrs (_: vm: vm.enable) cfg.vms;
  in {
    cfg.server.microvm.vms = listToAttrs (map (name: {
        inherit name;
        value = import (configLib.relativeToRoot "./hosts/microvm/${name}/meta.nix") cfg;
      })
      (builtins.attrNames (builtins.readDir (configLib.relativeToRoot "./hosts/microvm"))));

    sops.secrets = attrsets.concatMapAttrs (_: vm: vm.secrets) vmsEnabled;

    microvm.host.enable = lib.mkForce true;
    users.users.microvm.extraGroups = lib.mkForce ["keys"]; # allow access to sops keys

    systemd.services."microvm-virtiofsd@".serviceConfig.TimeoutStopSec = 1;

    microvm.vms = with attrsets; let
      latest = import inputs.latest {
        system = "x86_64-linux";
        #overlays = [inputs.microvm.overlay];
      };
      latest-unstable = import inputs.latest-unstable {system = "x86_64-linux";};
    in
      mapAttrs (name: vm: {
        pkgs = latest;

        specialArgs = {
          configLib = import (configLib.relativeToRoot "./lib") {lib = latest.lib;};
          unstable = latest-unstable;

          inherit vmsEnabled inputs outputs;
          inherit (cfg) vmConf;
          vms = cfg.vms;
          hostNetwork = config.cfg.server.net;
        };

        config = {
          imports = with inputs; [
            microvm.nixosModules.host
            #microvm.nixosModules.microvm
            home-manager.nixosModules.home-manager
            #disko.nixosModules.disko

            (configLib.relativeToRoot "./config")
            (configLib.relativeToRoot "./hosts/microvm/${name}")
            (configLib.relativeToRoot "./presets/microvm.nix")

            sops-nix.nixosModules.sops
          ];

          networking.hostName = name;
          networking.domain = config.networking.domain;
          system.stateVersion = config.system.stateVersion;

          microvm = {
            host.enable = false;
            guest.enable = true;

            inherit (vm) vcpu mem hypervisor;

            interfaces = let
              mac = configLib.decToHex vm.id "";
              fullMAC = "02:00:00:00:01:${configLib.strings.zeroPad 2 mac}";
            in [
              {
                #type = "bridge";
                #bridge = "virbr0";

                type = "tap";

                id = "vmtap${toString vm.id}";
                mac = fullMAC;
              }
            ];

            shares =
              vm.shares
              ++ [
                {
                  proto = "virtiofs";
                  tag = "ro-store";
                  source = "/nix/store"; # the entire store is world-readable and this config is
                  mountPoint = "/nix/.ro-store"; # public, so there's no risk in exposing it to VMs
                }
              ];
          };
        };
      })
      vmsEnabled;
  });
  */
}
