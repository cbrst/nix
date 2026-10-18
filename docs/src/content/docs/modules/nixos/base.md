---
title: Base system
description: Nix settings, garbage collection, and system-wide essentials for every NixOS host.
sidebar:
  order: 1
---

[`modules/nixos/base.nix`](https://github.com/cbrst/nix/blob/main/modules/nixos/base.nix)
is imported by the [desktop profile](/nix/profiles/nixos/#desktop).

## Nix

- Enables the `nix-command`, `flakes`, and `ca-derivations` experimental
  features.
- **Garbage collection** runs weekly and deletes generations older than 30
  days. Before it runs, the system profile is trimmed to the last 10
  generations, so the count limit applies first and the age limit second.

## Activation diff

An activation script runs [nvd](https://khumba.net/projects/nvd/) on every
`nixos-rebuild switch` (including dry activations) and prints the package
version changes between the running system and the new one.

## Essentials

- Zsh is enabled system-wide so it can be the login shell.
- `btop` and `nvd` are installed for all users.
- `system.stateVersion` is `26.05`. It controls compatibility defaults, not
  package versions, and must not be changed when upgrading.
