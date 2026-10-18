---
title: Home profiles
description: Bundles of Home Manager modules for user environments.
sidebar:
  order: 1
---

Home profiles live in
[`profiles/home/`](https://github.com/cbrst/nix/tree/main/profiles/home) and
group [Home Manager modules](/nix/modules/home/shell/) by role. Profiles build
on each other so that every machine shares one base.

```text
minimal
└── development
desktop-base
├── desktop-linux
└── desktop-macos
gaming
```

## minimal

A small command-line environment for any user machine:
[shell](/nix/modules/home/shell/), [SSH](/nix/modules/home/small-modules/#ssh),
[version control](/nix/modules/home/vcs/), and the
[1Password](/nix/modules/home/small-modules/#1password) CLI and SSH agent.
Bitwarden is available as a drop-in alternative to 1Password but is not
imported.

## development

Everything in `minimal`, plus:

- [Neovim](/nix/modules/home/neovim/) and its shared editor tooling.
- [VS Code](/nix/modules/home/small-modules/#vs-code) (application only).
- [AI tooling](/nix/modules/home/ai/): Claude Code, Serena, RTK, and agents.
- [direnv](/nix/modules/home/small-modules/#direnv) with nix-direnv, and
  LazyDocker.
- Node.js, with the npm global prefix moved to `~/.local/share/npm` so global
  installs work without root, and its `bin` directory added to `PATH`.

The [Emacs](/nix/modules/home/emacs/) module is complete but currently not
imported.

## desktop-base

The portable desktop pieces that work on Linux and macOS: the
[Ghostty](/nix/modules/home/ghostty/) terminal and the 0xProto and 0xPropo
fonts.

## desktop-linux

`desktop-base`, plus the Linux desktop applications:
[Niri](/nix/modules/home/niri/) and [Noctalia](/nix/modules/home/noctalia/)
configuration, [Firefox](/nix/modules/home/firefox/),
[Nautilus extensions, imv, mpv, Affinity, Brave, Nextcloud, Sone, and the
Tailscale tray](/nix/modules/home/desktop-apps/).

## desktop-macos

`desktop-base`, plus the [Karabiner-Elements](/nix/modules/home/karabiner/)
configuration and Ice, a menu bar manager.

## gaming

[MangoHud](/nix/modules/home/small-modules/#mangohud) with a toggle key, and
Prism Launcher for Minecraft. It complements the system-level
[gaming module](/nix/modules/nixos/gaming/).
