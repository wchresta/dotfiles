{
  inputs = {
    nixpkgs.url = "nixpkgs";

    light-control-flake.url = "light-control";
    light-control-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, ... }: {
    homeConfiguration = {
      "monoid@monoid" = args@{ ... }: {
        imports = [ ./home.nix ./extras/monoid.nix ];

        nixpkgs = {
          overlays = [
            (final: prev:
              if inputs ? light-control-flake then {
                light-control = inputs.light-control-flake.packages.${prev.system}.light-control;
              } else {}
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