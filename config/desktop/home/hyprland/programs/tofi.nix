{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.cfg.desktop.environment.hyprland;
in {
  config = lib.mkIf cfg.enable {
    home-manager.users =
      lib.attrsets.mapAttrs (name: _: {
        home.file.".config/tofi/config".text = ''
          width = 100%
          height = 100%
          border-width = 0
          outline-width = 0
          padding-left = 35%
          padding-top = 35%
          result-spacing = 25
          background-color = #000A
          num-results = 5
          font = ${pkgs.meslo-lgs-nf}/share/fonts/truetype/MesloLGS NF Regular.ttf
        '';
      })
      config.cfg.core.users;
  };
}
