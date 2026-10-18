---
title: Generated and external state
description: What Nix generates, and what intentionally lives outside the repository.
sidebar:
  order: 4
---

## Generated files

Home Manager turns source files in this repository into files in the home
directory. Modules keep their assets next to `default.nix`, often under
`configs/`, and install them with:

- `xdg.configFile` and `home.file`, which link files into `~/.config` and `~`.
- `environment.etc` on NixOS, for files under `/etc`.
- `writeShellApplication`, which wraps a script with its runtime dependencies
  on `PATH`.
- `configLib.renderTemplate`, which substitutes theme and font values (see
  [Settings and themes](/nix/architecture/settings-and-themes/)).

The results live in `/nix/store` and are read-only. Editing them directly does
nothing useful; change the source here and rebuild.

A few files are deliberately left writable. Claude Code's
`~/.claude/settings.json` is kept mutable so changes made with `/config` stick,
and the declared keys are merged over it on each activation.

## State outside the repository

These are intentionally not declarative. Do not add them to the flake:

| State | Why it stays outside |
| --- | --- |
| Account passwords | Set with `passwd`; secrets never go into the flake |
| `/var/lib/sbctl` | Secure Boot keys generated on the machine |
| `~/.ssh/hosts` | Personal SSH host entries, included by the SSH module |
| Password-manager agent sockets | Provided at runtime by 1Password or Bitwarden |
| Karabiner-Elements application | Needs root-owned services and a DriverKit extension that Home Manager cannot install |
| Raycast application | Updates itself; Home Manager replacing the bundle broke its data |

Credentials, password hashes, SSH private keys, Secure Boot keys, and vault
exports must never be committed.
