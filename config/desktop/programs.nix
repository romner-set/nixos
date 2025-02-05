{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.desktop.programs;
in {
  options.cfg.desktop.programs = {
    enable = mkEnableOption "";
    excludedPackages = mkOption {
      type = types.listOf types.package;
      default = [];
    };

    steam.openFirewall = mkEnableOption "";
    steam.enable = mkOption {
      type = types.bool;
      default = true;
    };
    zerotier.enable = mkEnableOption "";

    dev.enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    ### PROGRAMS ###
    programs.adb.enable = cfg.dev.enable;

    programs.steam = mkIf cfg.steam.enable {
      enable = true;
      remotePlay.openFirewall = cfg.steam.openFirewall;
      dedicatedServer.openFirewall = cfg.steam.openFirewall;
      gamescopeSession.enable = true;
      extraPackages = with pkgs; [xorg.libSM.out];
    };
    programs.virt-manager.enable = true;
    services.zerotierone.enable = cfg.zerotier.enable;

    services.tor.enable = true;
    services.tor.client.enable = true;

    ### PACKAGES ###
    environment.systemPackages = with pkgs; let
      vivaldiFixed = pkgs.vivaldi.overrideAttrs (oldAttrs: {
        dontWrapQtApps = false;
        dontPatchELF = true;
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pkgs.kdePackages.wrapQtAppsHook];
      });
    in
      lists.subtractLists cfg.excludedPackages (
        (
          lib.optionals cfg.dev.enable
          [
            gh
            #git-credential-manager
            cargo
            rustc
            yarn-berry
            nodejs
            arduino-ide
            arduino-cli
            screen
            (python3.withPackages (python-pkgs: [
              python-pkgs.pyserial
            ]))
            gcc
            bintools
            zig
            # (cutter.withPlugins (ps: with ps; [jsdec rz-ghidra sigdb]))
          ]
        )
        ++ [
          # misc
          tor

          # desktop
          #cava # home-manager'd
          #sage
          kitty
          firefox
          vivaldiFixed
          vivaldi-ffmpeg-codecs
          discord
          mullvad-browser
          tor-browser-bundle-bin
          obs-studio
          qbittorrent
          floorp
          vlc
          #qalculate-qt
          speedcrunch
          onlyoffice-bin
          moonlight-qt
          obsidian
          tenacity
          prismlauncher
          element-desktop
          jellyfin-media-player
          feishin
          arma3-unix-launcher
          winetricks
          protontricks
          wineWowPackages.waylandFull
          brightnessctl
          playerctl
          kdePackages.xwaylandvideobridge
        ]
      );
  };
}
