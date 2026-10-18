---
title: Validating changes
description: Build and check changes without activating them.
sidebar:
  order: 4
---

The installed system and home directory always reflect the **last activated**
generation, not the working tree. A change has to be evaluated or built before
you can judge it; testing it against the installed programs only tests the old
generation.

Run these from `/etc/nix-config`. None of them activate anything.

```bash
# Evaluate the flake
nix flake show --no-write-lock-file .
nix flake check --no-build --no-write-lock-file .

# Build the system configurations
nix build --no-link '.#nixosConfigurations.asgard.config.system.build.toplevel'
nix build --no-link '.#nixosConfigurations.example-nixos.config.system.build.toplevel'

# Build Asgard's embedded Home Manager configuration
nix build --no-link \
  '.#nixosConfigurations.asgard.config.home-manager.users.cbrst.home.activationPackage'

# Build or evaluate the standalone Home Manager outputs
nix build --no-link '.#homeConfigurations."example-user@generic-linux".activationPackage'
nix eval '.#homeConfigurations."example-user@macbook".activationPackage.drvPath'
nix eval '.#homeConfigurations."cbrst@niflheim".activationPackage.drvPath'
```

`--no-link` avoids creating a `result` symlink in the repository. The macOS
outputs can only be evaluated on Linux, not built.

:::note
Nix evaluates the flake from the Git snapshot of the repository. A newly
created file that Git does not know about yet is invisible to the evaluation.
In this colocated jj repository, running any `jj` command snapshots new files
into the working-copy commit.
:::

## Activating

Activation is a separate, explicit step:

```bash
# Asgard: system and Home Manager together
sudo nixos-rebuild switch --flake /etc/nix-config#asgard

# Niflheim or another standalone Home Manager host
nix run github:nix-community/home-manager -- switch --flake '.#cbrst@niflheim'
```

On NixOS, every activation prints a package-version diff between the running
system and the new one, produced by `nvd` (see [Base system](/nix/modules/nixos/base/)).

## Editor configurations

Neovim and Emacs have their own fast validation paths that load the
configuration straight from the checkout. See [Neovim](/nix/modules/home/neovim/#validating-changes)
and [Emacs](/nix/modules/home/emacs/).

## Updating inputs

`nix flake update` advances every pinned input in `flake.lock`. Only run it
deliberately; it changes the versions of every package and module the next
build uses.
