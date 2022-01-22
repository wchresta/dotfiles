{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ghc

    # Go and editor support
    go
    gopls
    go-outline
    goimports
    golint
    gopkgs
    go-check
    delve  # debugger
    go-tools

    (writeScriptBin "initgo" ''
      PROJNAME=''${PWD##*/}

      mkdir -p cmd/$PROJNAME
      cat > cmd/$PROJNAME/main.go <<EOF
      package main

      import "fmt"

      func main() {
        fmt.Printf("Hello World!")
      }
      EOF

      mkdir -p pkg/

      cat > flake.nix <<EOF
      {
        inputs = {
          flake-utils.url = "github:numtide/flake-utils";
        };

        outputs = { self, nixpkgs, flake-utils }:
          flake-utils.lib.eachDefaultSystem (system:
            let
              pkgs = import nixpkgs { inherit system; };

              $PROJNAME = pkgs.buildGoModule {
                pname = "$PROJNAME";
                version = "0.1.0";

                src = ./.;

                vendorSha256 = "";
              };
            in {
              packages = { inherit $PROJNAME; };
              defaultPackage = $PROJNAME;

              devShell = pkgs.mkShell {
                inputsFrom = builtins.attrValues self.packages.${system};
                buildInputs = with pkgs; [
                  pkgs.go_1_17
                  pkgs.gotools
                  pkgs.golangci-lint
                  pkgs.gopls
                  pkgs.go-outline
                  pkgs.gopkgs
                ];
              };
            });
      }
      EOF

      cat > go.mod <<EOF
      module github.com/wchresta/$PROJNAME

      go 1.17
      EOF

      ${pkgs.git}/bin/git init .
      ${pkgs.git}/bin/git add .
      ${pkgs.git}/bin/git commit -m "initgo"
    '')
  ];

  programs.git = {
    enable = true;

    userEmail = "34962284+wchresta@users.noreply.github.com";
    userName = "wchresta";

    extraConfig = {
      core = {
        editor = "nvim";
      };

      pull = {
        rebase = true;
      };
    };
  };

  # vsliveshare needs a provider for org.freedesktop.secrets
  services.gnome-keyring.enable = true;
  programs.vscode = {
    enable = true;
    # Turns out, most extensions are a bit out of date
    extensions = with pkgs.vscode-extensions; [
      ms-vsliveshare.vsliveshare
      ms-python.python
    ];
  };
}
