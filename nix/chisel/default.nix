{
  lib,
  pkgs,
  fetchMillDeps,
  publishMillJar,
  fetchFromGitHub,
  git,
}:
let
  chiselSrc =
    let
      # We lock modules by nvfetcher.toml
      # To update modules, run: nix run github:berberman/nvfetcher in chisel folder
      sources = ./_sources/generated.nix;
      deps = lib.filterAttrs (_: v: v ? src) (pkgs.callPackage sources { });
    in
    deps.chisel.src;
in
publishMillJar rec {
  name = "chisel";
  src = chiselSrc;

  publishTargets = [
    "unipublish"
  ];

  passthru = {
    chiselDeps = fetchMillDeps {
      name = "chisel";
      src = chiselSrc;
      millDepsHash = "sha256-ukG2oObq2GGeyjVtr8QiwNMnXPs6iX6ZvFiAFjR7ifk=";
    };
  };

  buildInputs = [
    passthru.chiselDeps.setupHook
  ];

  nativeBuildInputs = [
    # chisel requires git to generate version
    git
  ];

}
