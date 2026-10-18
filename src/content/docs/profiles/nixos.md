---
title: NixOS profiles
description: Bundles of NixOS modules for system roles.
sidebar:
  order: 2
---

NixOS profiles live in
[`profiles/nixos/`](https://github.com/cbrst/nix/tree/main/profiles/nixos).

## desktop

A complete Wayland desktop. It allows unfree packages (needed for 1Password),
adds the NUR overlay, and imports:

| Module | Provides |
| --- | --- |
| [base](/nix/modules/nixos/base/) | Flakes, garbage collection, Zsh, generation diffs |
| [network](/nix/modules/nixos/network/) | DNS, firewall, Tailscale |
| [desktop modules](/nix/modules/nixos/desktop/) | Niri, Noctalia and its greeter, PipeWire, fonts, GTK, Nautilus, multimedia, archives |
| [1Password](/nix/modules/nixos/desktop/#1password) | The CLI and GUI with polkit integration |

## development

System-level development tools: [rootless Docker and JetBrains
IDEs](/nix/modules/nixos/development/). Both Asgard and `example-nixos` import
it.
