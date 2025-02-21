{
  lib,
  config,
  ...
}: {
  services.fprintd.enable = true;

  services.keyd = {
    enable = true;
    keyboards.internal = {
      ids = ["0001:0001:70533846"];
      settings = {
        main.media = "home";
        shift.media = "end";
      };
    };
  };
}
