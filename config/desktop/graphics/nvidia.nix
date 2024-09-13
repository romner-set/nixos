{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.cfg.desktop.graphics.nvidia.enable {
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
      #package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}
