# Profiles

A profile is a named composition of modules for a role. It should describe what
a machine or user is for, not which physical computer it is.

For example, the `development` profile imports Git, a shell, and Neovim. A
laptop and a desktop can both use it. A host chooses profiles through its
`imports` list.

- `nixos/` bundles system-level NixOS modules.
- `home/` bundles portable Home Manager modules.

Profiles may import other profiles. Keep the chain shallow and give profiles
clear role-based names such as `minimal`, `development`, `desktop`, or `server`.
