{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.cfg.core.services;
in {
  options.cfg.core.services.ssh = {
    enable = mkEnableOption "";

    openFirewall = mkEnableOption "";
    ports = mkOption {
      type = types.listOf types.port;
      default = [22];
    };

    keys = mkOption {
      type = types.listOf types.singleLineStr;
      default = [];
    };
    passwordAuth = mkEnableOption "";
  };
  options.cfg.core.services.endlessh.enable = mkEnableOption "";

  config = {
    # OpenSSH
    services.openssh = mkIf cfg.ssh.enable {
      enable = true;
      openFirewall = cfg.ssh.openFirewall;
      ports = cfg.ssh.ports;
      settings = {
        PasswordAuthentication = cfg.ssh.passwordAuth;
        KbdInteractiveAuthentication = false;
      };
      extraConfig = ''
        TCPKeepAlive yes
        ClientAliveInterval 60
        ClientAliveCountMax 5
      '';
    };

    users.users.root.openssh.authorizedKeys.keys = cfg.ssh.keys;

    # endlessh
    services.endlessh-go.enable = cfg.endlessh.enable;
    services.endlessh-go.port = 22;
  };
}
