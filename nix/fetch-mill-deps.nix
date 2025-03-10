{
  stdenvNoCC,
  mill,
  writeText,
  makeSetupHook,
  runCommand,
  lib,
  configure-mill-home-hook,
  lndir,
}:

{
  name,
  src,
  millDepsHash,
  fetchTargets ? [ "__" ], # "__" means resolve all targets ivy deps
  ...
}@args:

let
  self = stdenvNoCC.mkDerivation (
    lib.recursiveUpdate
      {
        name = "${name}-mill-deps";
        inherit src;

        nativeBuildInputs = [
          mill
          configure-mill-home-hook
        ] ++ (args.nativeBuildInputs or [ ]);

        impureEnvVars = [ "JAVA_OPTS" ];

        buildPhase =
          ''
            runHook preBuild

            # Use "https://repo1.maven.org/maven2/" only to keep dependencies integrity
            export COURSIER_REPOSITORIES="ivy2local|central"
          ''
          + (lib.concatMapStrings (x: "mill -i '${x}'.prepareOffline\n") fetchTargets)
          + ''
            mill -i __.scalaCompilerClasspath

            runHook postBuild
          '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/.cache
          mv "$NIX_MILL_HOME"/.cache/coursier $out/.cache/coursier

          runHook postInstall
        '';

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = millDepsHash;

        dontShrink = true;
        dontPatchELF = true;

        passthru.setupHook =
          makeSetupHook
            {
              name = "mill-setup-hook.sh";
              propagatedBuildInputs = [
                mill
                configure-mill-home-hook
              ];
            }
            (
              writeText "mill-setup-hook" ''
                setup${name}MillCache() {
                  mkdir -p "$NIX_MILL_HOME/.cache/coursier"
                  ${lndir}/bin/lndir "${self}"/.cache/coursier "$NIX_MILL_HOME"/.cache/coursier

                  echo "Copied mill deps into $NIX_MILL_HOME"
                }

                postUnpackHooks+=(setup${name}MillCache)
              ''
            );
      }
      (
        builtins.removeAttrs args [
          "name"
          "src"
          "millDepsHash"
          "nativeBuildInputs"
        ]
      )
  );
in
self
