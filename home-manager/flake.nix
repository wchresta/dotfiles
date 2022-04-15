{
  inputs = {
    nixpkgs.url = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    light-control-flake.url = "light-control";
    light-control-flake.inputs.nixpkgs.follows = "nixpkgs";

    monoid-secrets = {
      flake = false;
      url = "path:/home/monoid/.config/nix/secrets.nix";
    };
  };

  outputs = inputs@{ self, nixpkgs-unstable, monoid-secrets, ... }: {
    homeConfiguration = {
      "monoid@monoid" = args@{ ... }: {
        imports = [ ./home.nix ./extras/monoid.nix ];

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
        imports = [ ./home.nix ./extras/comonoid.nix ];
      };
    };
  };
}
