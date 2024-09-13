{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.desktop.graphics;
in {
  imports = configLib.scanPath ./.;

  options.cfg.desktop.graphics = {
    nvidia.enable = mkEnableOption "Nvidia";
    amdgpu.enable = mkEnableOption "AMDGPU";
  };

  config.hardware = optionalAttrs (cfg.nvidia.enable || cfg.amdgpu.enable) {
    # 24.05 uses hardware.opengl, unstable uses hardware.graphics
    graphics.enable = true;
    graphics.enable32Bit = true;
  };
}
