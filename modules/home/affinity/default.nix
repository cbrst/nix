{ inputs, pkgs, ... }:
let
  # Built from affinity-nix's own nixpkgs so the uncacheable Wine prefix is only
  # rebuilt when the affinity-nix input changes, not on every nixpkgs update.
  affinityPkgs = import inputs.affinity-nix.inputs.nixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
    overlays = [ inputs.affinity-nix.overlays.default ];
  };
in
{
  home.packages = [ affinityPkgs.affinity-v3 ];
}
