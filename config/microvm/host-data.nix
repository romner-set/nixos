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
    inherit (cfg) vms vmsEnabled;
    self = vms."${config.networking.hostName}";
    hexId = configLib.strings.zeroPad 2 (configLib.decToHex self.id "");
  in
    mkIf cfg.enable {
      networking.hostName = lib.mkForce misc.selfName or "";
      networking.hostId = lib.mkForce "f0aef1${hexId}";
      system.stateVersion = lib.mkForce config.system.nixos.release; # VMs are ephemeral, so stateVersion should always be latest

      cfg.server.microvm.enable = lib.mkForce false;

      # users
      users.users = attrsets.concatMapAttrs (vmName: vm:
        builtins.listToAttrs (lists.imap0 (i: name: {
            name = "vm-${name}";
            value = {
              uid = mkForce (100000 + vm.id * 100 + i);
              isSystemUser = mkForce true;
              group = mkForce "vm-${vmName}";
            };
          })
          vm.users))
      (attrsets.filterAttrs (_: vm: vm.users != []) vmsEnabled);
      users.groups =
        attrsets.mapAttrs' (vmName: vm: {
          name = "vm-${vmName}";
          value.gid = mkForce (100000 + vm.id * 100);
        })
        (attrsets.filterAttrs (_: vm: vm.users != []) vmsEnabled);

      microvm = {
        guest.enable = lib.mkForce true;

        inherit (self) mem vcpu hypervisor;

	#mem = self.fixedMem;
	#balloonMem = self.mem;
	#hugepageMem = true;

	virtiofsd.extraArgs = ["--cache=metadata" "--allow-mmap"];
	#virtiofsd.inodeFileHandles = "prefer";
	virtiofsd.threadPoolSize = "0";

        interfaces = [
          {
            #type = "bridge";
            #bridge = "virbr0";

            type = "tap";

            id = "vmtap${toString self.id}";
            mac = "02:00:00:00:01:${hexId}";
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
