{
  description = "nixie development flake";

  # Locked to the same nixpkgs revision as the root flake, so nothing extra is
  # fetched. Re-pin with:
  #   nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/<rev>
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    {
      packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./. { };
      });

      # nix develop ./packages/nixie, then edit nixie.sh and run nixie-dev:
      # the working-tree script runs directly, without a rebuild.
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          nixie-dev = pkgs.writeShellScriptBin "nixie-dev" ''
            root=$(${pkgs.gitMinimal}/bin/git rev-parse --show-toplevel)
            export NIXIE_FLAKE=''${NIXIE_FLAKE:-$root}
            exec ${pkgs.bash}/bin/bash -o errexit -o nounset -o pipefail \
              "$root/packages/nixie/nixie.sh" "$@"
          '';
        in
        {
          default = pkgs.mkShellNoCC {
            packages = self.packages.${system}.default.runtimeInputs ++ [
              nixie-dev
              pkgs.shellcheck
              pkgs.shfmt
            ];
            shellHook = ''
              echo "nixie-dev runs the working-tree nixie.sh against \$NIXIE_FLAKE (default: this checkout)."
              echo "Lint with: shellcheck -s bash nixie.sh"
            '';
          };
        }
      );
    };
}
