{
  description = "Flake for building my website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    website-builder.url = "github:rasmus-kirk/website-builder";
    website-builder.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    website-builder,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    packages = forAllSystems ({pkgs}: let
      website = website-builder.lib {
        pkgs = pkgs;
        src = ./.;
        headerTitle = "Rasmus Kirk";
        articleDirs = ["articles" "misc"];
        standalonePages = [{inputFile = ./index.md;}];
        navbar = [
          {
            title = "About";
            location = "/";
          }
          {
            title = "Articles";
            location = "/articles";
          }
          {
            title = "Misc";
            location = "/misc";
          }
          {
            title = "Github";
            location = "https://github.com/rasmus-kirk";
          }
        ];
      };
    in {
      default = website.package;
      debug = website.loop;
    });

    formatter = forAllSystems ({pkgs}: pkgs.alejandra);
  };
}
