---
title: Noctalia
description: "The desktop shell: bar, launcher, notifications, idle handling, and lock screen."
sidebar:
  order: 10
---

[Noctalia](https://github.com/noctalia-dev/noctalia) is the desktop shell that
runs on top of [Niri](/nix/modules/home/niri/). The NixOS
[desktop module](/nix/modules/nixos/desktop/#noctalia) enables it and its
greeter; the Home Manager module in
[`modules/home/noctalia/`](https://github.com/cbrst/nix/tree/main/modules/home/noctalia)
writes its settings and palette.

## Theming

`configs/config.toml` is rendered with the shared monospace font, and
`configs/palette.json` with both palettes of the active
[theme family](/nix/architecture/settings-and-themes/), so the shell follows the
same light and dark colours as everything else.

## Bar

A translucent, rounded, shadowed bar with widgets placed directly rather than
in capsules:

- **Centre:** clock and weather.
- **End:** an accordion group holding the audio visualiser and media controls,
  then the system tray, a network toolkit widget, status, Taildrop, notifications,
  clipboard, volume, and the session menu.

## Panels

`Mod+Space` opens the launcher and `Mod+V` the clipboard history. The
control panel includes network, status, and Taildrop controls. Media keys drive
Noctalia's volume and media actions, and its on-screen display shows the result.

## Idle and lock

After 5 minutes of inactivity the session locks; after 20 minutes it suspends.
The lock screen shows a login box with a Caps Lock warning. `libnotify` is
installed so applications and scripts can send notifications.

## Wallpaper from Nautilus

The [Nautilus extension](/nix/modules/home/desktop-apps/#nautilus) adds "Set as
Noctalia Wallpaper" to the context menu of images.
