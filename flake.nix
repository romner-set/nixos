{
  inputs = {
    ### Globally auto-updated ###
    latest.url = "nixpkgs/nixos-24.11"; # used by VPSs & microvms for security's sake, updated every 24h (or less)
    latest-unstable.url = "nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko"; #TODO: use disko for desktops & servers
    disko.inputs.nixpkgs.follows = "latest";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "latest";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "latest";

    ### Manually updated ###

    # Desktops
    desktop.url = "nixpkgs/nixos-unstable"; #TODO: setup auto-update?

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "desktop";

    # Servers
    server.url = "nixpkgs/nixos-24.11"; #TODO: setup auto-update?
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
    nur,
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
          ({config, ...}: let
            cert =
              {
                "cynosure.red" = ''
                  -----BEGIN CERTIFICATE-----
                  MIIBrzCCATSgAwIBAgIQUEb2zgqDPLTnkBF6ab9soTAKBggqhkjOPQQDAzAXMRUw
                  EwYDVQQDEwxjeW5vc3VyZS5yZWQwHhcNMjQxMDI1MTIxMTA5WhcNMzQxMDIzMTIx
                  MTA5WjAXMRUwEwYDVQQDEwxjeW5vc3VyZS5yZWQwdjAQBgcqhkjOPQIBBgUrgQQA
                  IgNiAAQF/GB6aMoNk4nW4Y74qtxxUPSEZUFBeJeIloongHM+jRXsmP3WJ5XHIJWb
                  q/MOEsYJ8IDRGrlae4L4bCaDxIVbrQSJnJJ8YD6YxfskJKLjyzKh6jxbN5sA+9n0
                  dkWYEp2jRTBDMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEBMB0G
                  A1UdDgQWBBRO7WxcOL7bAbtxCgT7XwuDDHlc8DAKBggqhkjOPQQDAwNpADBmAjEA
                  lPIxXN1FfSjc5sWnd+XJHvIwTwl/PRExMtE1nwQv9iwDt6Mf2d72+ROHqC5QOiuE
                  AjEAw5/ncrp8nETasGJaSRWhAVgD8ktD+u0rCmIxrNYxy4w6uPPwGr5i+fcvxG1u
                  Ydmm
                  -----END CERTIFICATE-----
                '';
              }
              .${config.networking.domain};
          in {
            microvm = {
              guest.enable = false; # the microvm modules need to be imported,
              host.enable = false; # but should only be enabled when necessary
            };

            # include internal CA for domain
            security.pki.certificates = [cert];
            environment.etc."ssl/domain-ca.crt".text = cert;
          })

          # Misc. modules
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
	  nur.modules.nixos.default

          # options.cfg.* declarations
          ./config
          # options.svc.* declarations
          ./services
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

                /*
                  channels.nixpkgs.config.allowUnfreePredicate = pkg:
                  builtins.elem (channels.nixpkgs.ref.lib.getName pkg) [
                    "zerotierone"
                  ];
                channels.unstable.config.allowUnfreePredicate = pkg:
                  builtins.elem (channels.unstable.ref.lib.getName pkg) [
                    "factorio-headless"
                  ];
                */

                # microvm/starr - sonarr
                channels.nixpkgs.config.permittedInsecurePackages = [
                  "aspnetcore-runtime-6.0.36"
                  "aspnetcore-runtime-wrapped-6.0.36"
                  "dotnet-sdk-6.0.428"
                  "dotnet-sdk-wrapped-6.0.428"
                ];

                modules = [./hosts/server/${hypervisorName}/meta.nix];
                extraArgs.misc = {inherit hypervisorName selfName;};
              };
            }) (builtins.attrNames (builtins.readDir ./hosts/microvm))
          )) (builtins.attrNames (builtins.readDir ./hosts/server)))
          ++
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
          #
          # Testbeds
          #
          (map (name: {
            inherit name;
            value = {
              system = "x86_64-linux";
              preset = "testbed";

              channels.nixpkgs.ref = latest;
              channels.unstable.ref = latest-unstable;
            };
          }) (builtins.attrNames (builtins.readDir ./hosts/testbed)))
        )
      );
  };
}
