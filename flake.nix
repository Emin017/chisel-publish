{
  description = "A flake that builds chisel and publishes it to github releases";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        packages = {
          publish = pkgs.callPackage ./nix/scope.nix { };
          default = self.packages.publish;
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages ];
        };
      }
    );
}
