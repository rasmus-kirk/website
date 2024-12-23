{
  description = "Flake for building my website";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = {nixpkgs, ...}: let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    packages = forAllSystems ({pkgs}: let 
      mkPandoc = import ./mkPandoc.nix { pkgs = pkgs; };
      mkPandocDebug = import ./mkPandoc.nix { pkgs = pkgs; debug = true; };
    in rec {
      pandoc = mkPandoc.package;
      debug = mkPandocDebug.package;
      default = pandoc;
    });

    devShells = forAllSystems ({pkgs}: let 
      mkPandocDebug = import ./mkPandoc.nix { pkgs = pkgs; debug = true; };
    in {
      default = pkgs.mkShell {
        buildInputs = [ 
          mkPandocDebug.script
          mkPandocDebug.loop
          mkPandocDebug.server
        ];
      };
    });

    formatter = forAllSystems ({pkgs}: pkgs.alejandra);
  };
}
