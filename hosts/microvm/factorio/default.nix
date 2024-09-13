{
  lib,
  pkgs,
  unstable,
  config,
  ...
}:
with lib; {
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = ["60ee7c034ae7e677"];

  services.factorio = {
    enable = true;
    package = unstable.factorio-headless;

    game-name = "gaming";
    game-password = "gaming123";
    admins = ["Romner_set"];

    requireUserVerification = false;
    nonBlockingSaving = true;
    loadLatestSave = true;
  };
}
