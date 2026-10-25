# nixpkgs records a stale pnpmDeps fixed-output hash for
# typescript-language-server 6.0.2 on Darwin (the fetched pnpm store no longer
# hashes to the value pinned in
# pkgs/by-name/ty/typescript-language-server/package.nix, so every build fails
# with a hash mismatch). Pin the hash nix actually produces until nixpkgs picks
# up a fix upstream.
#
# Linux is left alone: there the fetch still matches the nixpkgs hash, and this
# pin made every Linux build fail instead.
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  typescript-language-server = prev.typescript-language-server.overrideAttrs (old: {
    pnpmDeps = old.pnpmDeps.override {
      hash = "sha256-PmyJb8090pEPc09Tbv8RgdvQpzpba2L8ve87+aVncQU=";
    };
  });
}
