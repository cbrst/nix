{
  lib,
  stdenv,
  writeShellApplication,
  coreutils,
  findutils,
  gawk,
  gitMinimal,
  gnugrep,
  gnused,
  gum,
  jq,
  jujutsu,
  nvd,
  util-linux,
}:

let
  # nix and nixos-rebuild come from the running system, so they match its
  # daemon and NixOS release.
  runtimeInputs = [
    coreutils
    findutils
    gawk
    gitMinimal
    gnugrep
    gnused
    gum
    jq
    jujutsu
    nvd
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux util-linux;
in
writeShellApplication {
  name = "nixie";
  inherit runtimeInputs;
  text = builtins.readFile ./nixie.sh;
  # The sub-flake's dev shell reuses these.
  passthru = { inherit runtimeInputs; };

  meta = {
    description = "Interactive management of this NixOS / Home Manager flake";
    mainProgram = "nixie";
    platforms = lib.platforms.unix;
  };
}
