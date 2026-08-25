# Home Manager Modules

Put portable user-level features here: command-line programs, editor
configuration, dotfiles, fonts, and applications installed into a user's home
directory.

Home Manager evaluates these modules on NixOS, other Linux distributions, and
macOS. If a module needs platform-specific behavior, use `pkgs.stdenv.isLinux`
or `pkgs.stdenv.isDarwin` inside the module rather than duplicating its common
configuration.

The `neovim/` directory is a feature module with its configuration files next to
its Nix definition.
