---
title: Desktop applications
description: Nautilus extensions, media viewers, and the other Linux desktop applications.
sidebar:
  order: 11
---

These modules are imported by the
[desktop-linux profile](/nix/profiles/home/#desktop-linux).

## Nautilus

The NixOS side installs Nautilus with GVfs (see
[desktop modules](/nix/modules/nixos/desktop/#nautilus)). The Home Manager
module in
[`modules/home/nautilus/`](https://github.com/cbrst/nix/tree/main/modules/home/nautilus)
adds a Python extension with two context-menu actions for a single selected
item:

| Selection | Action |
| --- | --- |
| A folder | **Open Folder as Slideshow**: plays every image and video in it, recursively and shuffled, full screen in mpv, five seconds per image |
| An image | **Set as Noctalia Wallpaper**: converts it to `~/Pictures/Wallpapers/wallpaper.jpg` and tells Noctalia to use it |

Both actions are shell scripts packaged with `writeShellApplication`, and their
store paths are substituted into the extension. The extension starts them as
Gio subprocesses and waits for them asynchronously, so a failure to start or a
non-zero exit is reported through GLib instead of being lost. The wallpaper
script sends a desktop notification on failure. Because Noctalia caches images
by path, it first shows a staged copy and then the final file.

## imv and mpv

- **imv** is the image viewer, with its background set to the theme's dark
  background colour.
- **mpv** is the video player, with the [uosc](https://github.com/tomasklaen/uosc)
  interface.

## Other applications

| Module | Provides |
| --- | --- |
| `affinity` | Affinity v3 creative applications, from the `affinity-nix` flake |
| `brave-origin` | The upstream Brave browser build |
| `nextcloud.nix` | The Nextcloud desktop sync client (Linux only; there is no macOS build) |
| `sone.nix` | Sone |
| `tailscale.nix` | The Tailscale system tray. The daemon is configured by the [network module](/nix/modules/nixos/network/) |
