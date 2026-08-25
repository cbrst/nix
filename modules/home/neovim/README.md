# Neovim Module

This directory keeps the Neovim installation and its personal configuration
together.

`default.nix` enables Neovim through Home Manager and links `init.lua` into
`~/.config/nvim/init.lua`. Add Lua files under `lua/` as the configuration
grows, then link that directory from the module as well.

The development profile imports this module, so every host using that profile
receives the same editor setup.
