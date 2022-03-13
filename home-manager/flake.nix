{
  inputs = {
    nixpkgs.url = "nixpkgs";

    light-control-flake.url = "light-control";
    light-control-flake.inputs.nixpkgs.follows = "nixpkgs";

    monoid-secrets = {
      flake = false;
      url = "path:/home/monoid/.config/nix/secrets.nix";
    };
  };

  outputs = inputs@{ self, monoid-secrets, ... }: {
    homeConfiguration = {
      "monoid@monoid" = args@{ ... }: {
        imports = [ ./home.nix ./extras/monoid.nix ];

        nixpkgs = {
          overlays = [
            (final: prev:
              {
                multimc = prev.multimc.override {
                  msaClientID = (import monoid-secrets {}).multimcClientID;
                };
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
