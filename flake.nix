{
  description = "Flake for building my website";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.website-builder.url = "github:rasmus-kirk/website-builder";

  outputs = {nixpkgs, website-builder, ...}: let
    website = pkgs: debug: website-builder.lib {
      pkgs = pkgs;
      articleDirs = [ ./articles ./misc ];
      standalonePages = [{ inputFile = ./index.md; }];
      debug = debug;
    };
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    packages = forAllSystems ({pkgs}: let 
      mkPandoc = website pkgs false;
      mkPandocDebug = website pkgs true;
    in rec {
      pandoc = mkPandoc.package;
      debug = mkPandocDebug.package;
      default = pandoc;
    });

    devShells = forAllSystems ({pkgs}: let 
      mkPandocDebug = website pkgs true;
    in {
      default = pkgs.mkShell {
        buildInputs = [ 
          mkPandocDebug.loop
        ];
      };
    });

    formatter = forAllSystems ({pkgs}: pkgs.alejandra);
  };
}
