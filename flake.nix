{
  inputs = {
    ### Globally auto-updated ###
    latest.url = "nixpkgs/nixos-24.05"; # used by VPSs & microvms for security's sake, updated every 24h (or less)
    latest-unstable.url = "nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko"; #TODO: use disko for desktops & servers
    disko.inputs.nixpkgs.follows = "latest";

    sops-nix.url = "github:Mic92/sops-nix"; #TODO: auto-update
    sops-nix.inputs.nixpkgs.follows = "latest";

    ### Manually updated ###

    # Desktops
    desktop.url = "nixpkgs/nixos-unstable"; #TODO: setup auto-update?

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "desktop";

    # Servers
    server.url = "nixpkgs/nixos-24.05"; #TODO: setup auto-update?
    server-unstable.url = "nixpkgs/nixos-unstable";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "server";
  };

  outputs = inputs @ {
    self,
    latest,
    latest-unstable,
    disko,
    desktop,
    home-manager,
    server,
    server-unstable,
    microvm,
    sops-nix,
  }: let
    inherit (self) outputs;
  in {
    formatter.x86_64-linux = latest.legacyPackages.x86_64-linux.alejandra;
    formatter.aarch64-linux = latest.legacyPackages.aarch64-linux.alejandra;

    ### Hosts ###

    nixosConfigurations = let
      # Stuff shared between all presets
      shared = {
        modules = [
          # MicroVM
          microvm.nixosModules.host
          microvm.nixosModules.microvm
          {
            microvm = {
              guest.enable = false; # the microvm modules need to be imported,
              host.enable = false; # but should only be enabled when necessary
            };
          }

          # Misc. modules
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops

          # options.cfg.* declarations
          ./config
        ];

        extraArgs = {
          inherit inputs outputs;
          misc = {};
        };
      };
    in
      builtins.mapAttrs (name: host: let
        nixpkgs = host.channels.nixpkgs;
        unstable = host.channels.unstable or nixpkgs;
      in
        nixpkgs.ref.lib.nixosSystem rec {
          system = host.system;

          pkgs = import nixpkgs.ref {
            inherit system;
            config = nixpkgs.config or {};
          };

          specialArgs =
            {
              configLib = import ./lib {inherit (nixpkgs.ref) lib;}; # configLib.relativeToRoot is used in imports, therefore needs to be in specialArgs
              unstable = import unstable.ref {
                inherit system;
                config = unstable.config or {};
              };
            }
            // (host.specialArgs or {});

          modules =
            shared.modules
            ++ (host.modules or [])
            ++ [
              {_module.args = shared.extraArgs // (host.extraArgs or {});}
              ./hosts/${host.preset}/${host.hostName or name}
              ./presets/${host.preset}.nix
            ];
        }) (
        builtins.listToAttrs (
          #
          # Desktops
          #
          (map (name: {
            inherit name;
            value = {
              system = "x86_64-linux";
              preset = "desktop";

              channels.nixpkgs.ref = desktop;
              channels.nixpkgs.config.allowUnfree = true;
            };
          }) (builtins.attrNames (builtins.readDir ./hosts/desktop)))
          ++
          #
          # Physical servers
          #
          (map (name: {
            inherit name;
            value = {
              system = "x86_64-linux";
              preset = "server";

              channels.nixpkgs.ref = server;
              channels.unstable.ref = server-unstable;
            };
          }) (builtins.attrNames (builtins.readDir ./hosts/server)))
          ++
          /*
          #
          # ARM VPSs
          #
          (map (name: {
            inherit name;
            value = {
              system = "aarch64-linux";
              preset = "vps";

              channels.nixpkgs.ref = latest;
              channels.unstable.ref = latest-unstable;
            };
          }) (builtins.attrNames (builtins.readDir ./hosts/vps)))
          ++
          */
          #
          # MicroVMs
          #
          (latest.lib.lists.concatMap (hypervisorName: (
            map (selfName: {
              name = "${hypervisorName}:${selfName}";
              value = rec {
                hostName = selfName;

                system = "x86_64-linux";
                preset = "microvm";

                channels.nixpkgs.ref = latest;
                channels.unstable.ref = latest-unstable;

                channels.nixpkgs.config.allowUnfreePredicate = pkg:
                  builtins.elem (channels.nixpkgs.ref.lib.getName pkg) [
                    "zerotierone"
                  ];
                channels.unstable.config.allowUnfreePredicate = pkg:
                  builtins.elem (channels.unstable.ref.lib.getName pkg) [
                    "factorio-headless"
                  ];

                modules = [./hosts/server/${hypervisorName}/meta.nix];
                extraArgs.misc = {inherit hypervisorName selfName;};
              };
            }) (builtins.attrNames (builtins.readDir ./hosts/microvm))
          )) (builtins.attrNames (builtins.readDir ./hosts/server)))
        )
      );
  };
}
