# Library Helpers

This directory contains small Nix functions used by `flake.nix`. It is not a
module directory: files here return helper functions rather than configuration
options.

`default.nix` exports `mkHome`, which removes repeated setup needed to create
standalone Home Manager configurations. NixOS uses `nixpkgs.lib.nixosSystem`
directly because it has its own system builder.
