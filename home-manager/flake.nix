{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    light-control-flake.url = "light-control";
    light-control-flake.inputs.nixpkgs.follows = "nixpkgs";

    simple-dbus-hook.url = "path:/home/monoid/src/simple-dbus-hook";
    simple-dbus-hook.inputs.nixpkgs.follows = "nixpkgs";

    monoid-secrets = {
      flake = false;
      url = "path:/home/monoid/.config/nix/secrets.nix";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, monoid-secrets, ... }:
    let
      channelOverlay = args: {
          xdg.configFile."nix/inputs/nixpkgs".source = nixpkgs.outPath;
          home.sessionVariables.NIX_PATH = "nixpkgs=${args.config.xdg.configHome}/nix/inputs/nixpkgs$\{NIX_PATH:+:$NIX_PATH}";

          nix.registry.nixpkgs.flake = nixpkgs;
        };
    in {
    homeConfiguration = {
      "monoid@monoid" = args@{ ... }: {
        imports = [ channelOverlay ./home.nix ./extras/monoid.nix ];

        nix.registry = {
          light-control.from = {
            id = "light-control";
            type = "indirect";
          };
          light-control.to = {
            type = "path";
            path = "/home/monoid/src/light-control";
          };
          containers.from = {
            id = "containers";
            type = "indirect";
          };
          containers.to = {
            type = "path";
            path = "/home/monoid/src/monoids";
          };
        };

        nixpkgs = {
          overlays = [
            (final: prev: let
              unstable = import nixpkgs-unstable {
                system = prev.system;
                config.allowUnfree = true;
              };
            in
              {
                multimc = prev.multimc.override {
                  msaClientID = (import monoid-secrets {}).multimcClientID;
                };

                lutris = unstable.lutris;
              } // (
              if inputs ? light-control-flake then {
                light-control = inputs.light-control-flake.packages.${prev.system}.light-control;
              } else {})
            )
          ];
        };
      };

      "monoid@comonoid" = args@{ ... }: {
        imports = [ channelOverlay ./home.nix ./extras/comonoid.nix ];

        nixpkgs.overlays = [
          (final: prev: { simple-dbus-hook = inputs.simple-dbus-hook.packages.${prev.system}.default; })
        ];
      };
    };
  };
}
