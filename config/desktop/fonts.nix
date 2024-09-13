{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.desktop.fonts;
in {
  options.cfg.desktop.fonts = {
    enable = mkEnableOption "";
  };

  config = let
    fontPkgs = with pkgs; [
      liberation_ttf
      meslo-lgs-nf
    ];
  in
    mkIf cfg.enable {
      environment.systemPackages = fontPkgs;
      fonts = {
        #enableDefaultPackages = true;
        packages = fontPkgs;
        fontconfig = {
          defaultFonts = {
            serif = ["Liberation Serif"];
            sansSerif = ["Liberation Sans"];
            monospace = ["MesloLGS NF"];
          };
        };
      };
    };
}
