{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "inithaskell" ''
      PROJNAME=''${PWD##*/}

      nix flake init --template templates#haskell-hello

      ${pkgs.git}/bin/git init .
      ${pkgs.git}/bin/git add .
      ${pkgs.git}/bin/git commit -m "inithaskell"
    '')

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

                vendorHash = "";
              };
            in {
              packages = {
                inherit $PROJNAME;
                default = $PROJNAME;
              };

              devShell = pkgs.mkShell {
                inputsFrom = [ $PROJNAME ];
                buildInputs = with pkgs; [
                  pkgs.go_1_22
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

    (writeScriptBin "initpy" ''
      PROJNAME=''${PWD##*/}

      mkdir -p src/$PROJNAME
      touch src/$PROJNAME/__init__.py

      cat > src/$PROJNAME/cli.py <<EOF
      def main():
          print("Hello world!")
      EOF

      mkdir -p tests/

      cat > pyproject.toml <<EOF
      [build-system]
      requires = [
          "setuptools>=42",
          "wheel"
      ]
      build-backend = "setuptools.build_meta"
      EOF

      cat > setup.cfg <<EOF
      [metadata]
      name = $PROJNAME
      version = 0.1.0
      author = Wanja Chresta
      description = Some package
      long_description = file: README.md
      long_description_content_type = text/markdown
      url = https://github.com/wchresta/$PROJNAME
      project_urls =
          Bug Tracker = https://github.com/wchresta/$PROJNAME/issues
      classifiers =
          Programming Language :: Python :: 3
          License :: OSI Approved :: Apache Software License
          Operating System :: OS Independent

      [options]
      package_dir =
          = src
      packages = find:
      python_requires = >=3.10

      [options.packages.find]
      where = src

      [options.entry_points]
      console_scripts =
          $PROJNAME = $PROJNAME.cli:main
      EOF

      cat > setup.py <<EOF
      #!/usr/bin/env python

      import setuptools

      if __name__ == "__main__":
          setuptools.setup()
      EOF

      touch requirements.txt

      cat > flake.nix <<EOF
      {
        outputs = { self, nixpkgs, flake-utils, mach-nix }:
          flake-utils.lib.eachDefaultSystem (system:
            let
              pkgs = import nixpkgs { inherit system; };

              mach-nix-lib = import mach-nix {
                inherit pkgs;
                python = "python310";
              };

              $PROJNAME = mach-nix-lib.buildPythonPackage ./.;
            in {
              packages = { inherit $PROJNAME; };
              defaultPackage = $PROJNAME;

              devShell = pkgs.mkShell {
                inputsFrom = builtins.attrValues self.packages.\''${system};
                buildInputs = with pkgs; [
                  black
                  mypy
                ];
              };
            });
      }
      EOF

      ${pkgs.git}/bin/git init .
      ${pkgs.git}/bin/git add .
      ${pkgs.git}/bin/git commit -m "initpy"
    '')
  ];
}
