---
title: Karabiner-Elements
description: Keyboard remapping on macOS.
sidebar:
  order: 12
---

[`modules/home/karabiner/`](https://github.com/cbrst/nix/tree/main/modules/home/karabiner)
links the checked-in `karabiner.json` into `~/.config/karabiner/`. It is part of
the [desktop-macos profile](/nix/profiles/home/#desktop-macos).

## What it maps

The only complex modification turns **Caps Lock into Left Control in terminals
and editors**, where Control chords matter most. Caps Lock keeps its normal
behaviour everywhere else.

## Installing the application

The module manages **only** the configuration file. Install Karabiner-Elements
with its official macOS installer before applying the profile.

Home Manager cannot install Karabiner's root-owned support files, system
launch daemons, or DriverKit system extension. Adding
`pkgs.karabiner-elements` would install the GUI applications but not a working
installation, so it is intentionally left out.
