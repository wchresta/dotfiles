{
  inputs = {
    nixpkgs.url = "nixpkgs";

    light-control-flake.url = "light-control";
    light-control-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, ... }: {
    homeConfiguration = args@{ ... }: {
      imports = [ ./home.nix ];

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
  };
}