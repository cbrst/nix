---
title: Using the templates
description: Turn the example hosts into a configuration for a new machine or user.
sidebar:
  order: 3
---

The flake ships three template outputs next to the real hosts. They use the
same profiles as Asgard and Niflheim, so a new machine starts from a working
setup rather than from scratch.

| Template | Use it for |
| --- | --- |
| `nixosConfigurations.example-nixos` | A new NixOS machine |
| `homeConfigurations."example-user@generic-linux"` | A user environment on Arch, Fedora, Ubuntu, and so on |
| `homeConfigurations."example-user@macbook"` | A user environment on macOS |

:::caution
`example-nixos` has placeholder disk and boot values (`/dev/sda` with GRUB). It
must not be applied unchanged.
:::

## Before applying

1. Replace every `example-*` name: the user account in the host file, the
   `users/example-user/` directory, and the output name in `flake.nix`.
2. Replace the Git and jj identity in `modules/home/vcs/default.nix`.
3. For NixOS, replace the template's `hardware-configuration.nix` with one that
   describes the real machine.
4. Keep `system.stateVersion` and `home.stateVersion` at the release the machine
   was first installed with. They control compatibility defaults, not package
   versions.

## Applying

```bash
# NixOS: configures the operating system and the user
sudo nixos-rebuild switch --flake .#example-nixos

# Linux or macOS: configures only the current user's home directory
nix run github:nix-community/home-manager -- switch \
  --flake .#example-user@generic-linux
```

## Adding a new host

1. Create `hosts/nixos/<name>/` or `hosts/home/<name>.nix`.
2. Publish the host's settings with `_module.args.settings`, either
   `defaultSettings` unchanged or with overrides layered on through
   `lib.recursiveUpdate`. See [Settings and themes](/nix/architecture/settings-and-themes/).
3. Import profiles, not individual modules, unless a feature really belongs to
   that one machine.
4. Add the output to `flake.nix` with `nixpkgs.lib.nixosSystem` or
   `configLib.mkHome`.

## External applications on macOS

Some macOS applications are installed outside Nix on purpose. Install
**Karabiner-Elements** with its official installer (the
[Karabiner module](/nix/modules/home/karabiner/) only manages its JSON file), and
install **Raycast** with its official installer or Homebrew. Home Manager
replaced the Raycast app bundle on every activation, which lost or broke its
databases and extensions, so it is no longer managed here.
