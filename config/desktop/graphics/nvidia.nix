{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.cfg.desktop.graphics.nvidia;
in {
  options.cfg.desktop.graphics.nvidia = {
    prime = {
      enable = mkEnableOption "";
      amdgpuBusId = mkOption {
        type = types.str;
        default = "";
      };
      intelBusId = mkOption {
        type = types.str;
        default = "";
      };
      nvidiaBusId = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    boot.blacklistedKernelModules = ["nouveau"];

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement.enable = false;
      powerManagement.finegrained = false; #TODO?
      nvidiaSettings = true;

      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      prime = mkIf cfg.prime.enable {
        inherit (cfg.prime) amdgpuBusId intelBusId nvidiaBusId;
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}
