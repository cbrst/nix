# Library Helpers

This directory contains small Nix functions used by `flake.nix`. It is not a
module directory: files here return helper functions rather than configuration
options.

`default.nix` exports `mkHome`, which removes repeated setup needed to create
standalone Home Manager configurations. NixOS uses `nixpkgs.lib.nixosSystem`
directly because it has its own system builder.

`themes.nix` holds the shared colour palettes. `import ./themes.nix { family = ...; }`
returns that family's semantic `light` and `dark` palettes, plus a derived
`terminal` set for each variant (16 ANSI colours, cursor and selection).

`colors.nix` provides pure hex colour arithmetic (`mix`, `lighten`, `darken`,
`hexToRgb`, `rgbToHex`, `stripHash`). `default.nix` exports it as
`configLib.colors`.
