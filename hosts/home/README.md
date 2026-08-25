# Standalone Home Manager Hosts

These files describe one user environment on machines that are not being managed
as NixOS systems. They are suitable for an existing Linux distribution or macOS
installation.

A standalone host selects Home Manager profiles. The user's common settings are
imported by the corresponding `homeConfigurations` entry in `../../flake.nix`.

Add a named `homeConfigurations."user@host"` output to `flake.nix`, then apply
it with:

```bash
nix run github:nix-community/home-manager -- switch --flake .#user@host
```
