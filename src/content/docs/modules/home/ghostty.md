---
title: Ghostty
description: The terminal emulator on Linux and macOS.
sidebar:
  order: 7
---

[`modules/home/ghostty/`](https://github.com/cbrst/nix/tree/main/modules/home/ghostty)
configures [Ghostty](https://ghostty.org) through the portable
[desktop-base profile](/nix/profiles/home/#desktop-base), so Asgard and Niflheim
share it. On macOS it installs the prebuilt `ghostty-bin` package; on Linux the
source-built `ghostty`.

## Appearance

- **Font:** the shared monospace family (`0xProto`) at the host's
  `fonts.terminalSize`, with the `ss01` stylistic set. Cell metrics use
  Ghostty's defaults; the earlier height and baseline adjustments are kept as
  comments for reference.
- **Theme:** follows the system appearance, using the light and dark theme
  names from the active [theme family](/nix/architecture/settings-and-themes/).
  The Meowsoot and Kanagawa Ghostty themes are linked from their pinned sources
  into `~/.config/ghostty/themes`.
- **Window:** a 2 px balanced padding that extends the background colour,
  unfocused splits dimmed to 50%, a thicker cursor, and the mouse hidden while
  typing. The GTK title bar is hidden on Linux; on macOS the title bar is
  transparent because the tabs style is buggy in Ghostty 1.3.1.

## Behaviour

Zsh integration is enabled, and the SSH integration features copy the
environment and terminfo to remote hosts. `CONFIG_POWERLINE_GLYPHS=1` tells the
shell prompt that powerline glyphs render correctly.

## Local overrides

The configuration loads an optional `config-custom` file next to the generated
one. The `?` prefix means a missing file is not an error, so you can add
machine-local tweaks without changing the flake.
