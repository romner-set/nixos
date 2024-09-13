{
  config,
  configLib,
  lib,
  pkgs,
  inputs,
  outputs,
  misc,
  ...
}:
with lib; let
  cfg = config.cfg.microvm.host;
in {
  options.cfg.microvm.host = {
    enable = mkEnableOption "";
    hostName = mkOption {
      type = types.str;
      default = misc.hypervisorName or "";
    };
    vmConf = mkOption {
      type = types.attrs;
      default = config.cfg.server.microvm.vmConf;
    };
    vms = mkOption {
      type = types.attrs;
      default = config.cfg.server.microvm.vms;
    };
    vmsEnabled = mkOption {
      type = types.attrs;
      default = attrsets.filterAttrs (_: vm: vm.enable) cfg.vms;
    };
    net = mkOption {
      type = types.attrs;
      default = config.cfg.server.net;
    };
  };

  config = let
    self = cfg.vms."${config.networking.hostName}";
    hexId = configLib.decToHex self.id "";
    hexIdPadded = "${
      if stringLength hexId == 1
      then "0"
      else ""
    }${hexId}";
    fullMAC = "02:00:00:00:01:${hexIdPadded}";
  in
    mkIf cfg.enable {
      networking.hostName = lib.mkForce misc.selfName or "";
      networking.hostId = lib.mkForce "f0aef1${hexIdPadded}";
      system.stateVersion = lib.mkForce config.system.nixos.release; # VMs are ephemeral, so stateVersion should always be latest

      cfg.server.microvm.enable = lib.mkForce false;

      microvm = {
        guest.enable = lib.mkForce true;

        inherit (self) vcpu mem hypervisor;

        interfaces = [
          {
            #type = "bridge";
            #bridge = "virbr0";

            type = "tap";

            id = "vmtap${toString self.id}";
            mac = fullMAC;
          }
        ];

        shares =
          self.shares
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
}
