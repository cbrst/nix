---
title: Niflheim
description: The Mac, configured with standalone Home Manager.
sidebar:
  order: 2
---

Niflheim is an Apple Silicon Mac (`aarch64-darwin`). Nix does not manage macOS
itself here; Home Manager configures only the `cbrst` user's environment. It is
exported as `homeConfigurations."cbrst@niflheim"` and its source is
[`hosts/home/niflheim.nix`](https://github.com/cbrst/nix/blob/main/hosts/home/niflheim.nix).

## What the host selects

- `users/cbrst/home.nix`, shared with Asgard.
- The [development](/nix/profiles/home/#development) profile, so the shell,
  version control, Neovim, and AI tooling match Asgard.
- The [desktop-macos](/nix/profiles/home/#desktop-macos) profile: Ghostty, the
  configured fonts, the Karabiner configuration, and Ice.
- `terminal-notifier`, installed at the host level because it is macOS-only.

## Host-specific values

The only settings override raises `fonts.terminalSize` to 14 for the higher
pixel density; every other host keeps 11.

## macOS specifics

- Ghostty uses the prebuilt `ghostty-bin` package and a transparent title bar,
  because the tabs-style title bar is buggy in Ghostty 1.3.1 on this macOS
  release.
- macOS updates restore `/etc/zshrc` and drop the Nix installer's hook, and
  `path_helper` moves system directories ahead of Nix. The
  [shell module](/nix/modules/home/shell/) loads the Nix daemon environment
  from the user's own startup files and puts the Nix profiles back at the front
  of `PATH`.
- Karabiner-Elements and Raycast are installed outside Nix. See
  [Generated and external state](/nix/architecture/external-state/).

## Applying

```bash
nix run github:nix-community/home-manager -- switch --flake '.#cbrst@niflheim'
```
