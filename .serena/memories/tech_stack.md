# Stack
- Nix flake with nixpkgs unstable, Home Manager, NixOS modules, Lua Neovim config, and Emacs Lisp config.
- `flake.nix` exports NixOS `asgard`, `example-nixos`; Home Manager `example-user@generic-linux`, `example-user@macbook`, `cbrst@niflheim`.
- Flow: flake output -> host -> profile -> module -> package/config output.
- Shared helpers/theme data in `lib/`; local derivations in `packages/`; source assets are linked/rendered through Home Manager.
- Neovim specifics: `mem:neovim/core`.