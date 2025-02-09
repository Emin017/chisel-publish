{ lib, newScope, ... }:
lib.makeScope newScope (scope: {
  configure-mill-home-hook = scope.callPackage ./config-home.nix { };
  fetchMillDeps = scope.callPackage ./fetch-mill-deps.nix { };
  publishMillJar = scope.callPackage ./publish-mill-jar.nix { };
  chisel = scope.callPackage ./chisel { };
})
