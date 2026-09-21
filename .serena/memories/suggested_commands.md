# Useful commands
- Inspect: `jj status`, `jj diff`, `jj diff --stat`.
- Evaluate: `nix flake check --no-build --no-write-lock-file .`.
- NixOS build: `nix build --no-link '.#nixosConfigurations.asgard.config.system.build.toplevel'`.
- Generic HM build: `nix build --no-link '.#homeConfigurations.\"example-user@generic-linux\".activationPackage'`.
- Neovim package build: `nix build --no-link '.#homeConfigurations.\"example-user@generic-linux\".config.programs.neovim.finalPackage'`.
- Use `--no-link`; avoid incidental lock updates and activation.