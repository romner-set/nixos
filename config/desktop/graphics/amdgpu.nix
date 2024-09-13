{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.cfg.desktop.graphics.amdgpu.enable {
    boot.initrd.kernelModules = ["amdgpu"];
    services.xserver.videoDrivers = ["amdgpu"];
  };
}
