# Nix Configuration

This repository is a starter layout for two related jobs:

- Configuring complete NixOS machines.
- Configuring one user on NixOS, other Linux distributions, and macOS through
  Home Manager.

The configuration is a [Nix flake](https://nixos.wiki/wiki/Flakes):
`flake.nix` names the external dependencies and exports named configurations.

## Layout

```text
flake.nix                 Entry points for machines and users
hosts/                    Small, machine-specific selections
modules/                  Independent, reusable features
profiles/                 Named bundles of features
users/                    Settings shared by one person across machines
overlays/                 Optional custom package changes
lib/                      Small helpers used by flake.nix
```

Configuration flows from an entry point to the selected host, profile, and
module:

```text
flake output -> host -> profile -> module -> installed/configured feature
```

See the README in each directory before replacing the examples with real
configuration.

## First use

Replace every `example-*` name, the placeholder Git identity, and the NixOS
hardware configuration before applying this repository. Generate the lock file
after choosing input versions:

```bash
nix flake lock
```

Apply the matching named output from `flake.nix`:

```bash
# NixOS: configures the operating system and the example user.
sudo nixos-rebuild switch --flake .#example-nixos

# Generic Linux or macOS: configures only the current user's environment.
nix run github:nix-community/home-manager -- switch \
  --flake .#example-user@generic-linux
```

Home Manager cannot configure system services or hardware on non-NixOS systems.
It manages packages and files in the selected user's home directory.
