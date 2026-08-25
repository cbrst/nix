# Modules

A Nix module is a function that returns configuration attributes. Modules are
the smallest reusable units in this repository: each owns one concern, such as
Git, a shell, Neovim, audio, or networking.

Modules are imported with an `imports` list. Nix combines their attribute sets
into one final configuration. If two modules set incompatible values, evaluation
fails; this makes configuration conflicts explicit.

- `nixos/` is for operating-system configuration and can only be used by NixOS.
- `home/` is for user configuration and can be used through Home Manager on
  NixOS, generic Linux, and macOS.

Profiles in `../profiles` import modules together. Hosts normally consume
profiles rather than importing many modules directly.
