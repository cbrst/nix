# nixpkgs records a stale pnpmDeps fixed-output hash for
# typescript-language-server 6.0.2 (the fetched pnpm store no longer hashes
# to the value pinned in pkgs/by-name/ty/typescript-language-server/package.nix,
# so every build fails with a hash mismatch). Pin the hash nix actually
# produces until nixpkgs picks up a fix upstream.
final: prev: {
  typescript-language-server = prev.typescript-language-server.overrideAttrs (old: {
    pnpmDeps = old.pnpmDeps.override {
      hash = "sha256-PmyJb8090pEPc09Tbv8RgdvQpzpba2L8ve87+aVncQU=";
    };
  });
}
