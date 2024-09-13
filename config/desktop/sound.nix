{
  config,
  lib,
  ...
}:
with lib; {
  options.cfg.desktop.sound.enable = mkEnableOption "pipewire";
  config = mkIf config.cfg.desktop.sound.enable {
    # sound.enable = true; # shouldn't be used with pw
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
