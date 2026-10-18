---
title: Secure Boot
description: Signing the Limine boot loader with locally generated keys.
sidebar:
  order: 5
---

[`modules/nixos/secure-boot.nix`](https://github.com/cbrst/nix/blob/main/modules/nixos/secure-boot.nix)
installs [sbctl](https://github.com/Foxboron/sbctl), which creates, enrolls, and
checks Secure Boot keys. The signing itself is done by the Limine boot loader:
with `boot.loader.limine.secureBoot.enable = true`, Limine signs its boot files
with the keys sbctl manages in `/var/lib/sbctl`.

The keys are generated on the machine and never stored in the repository.

## Why it takes two stages

A machine cannot boot signed files before its keys are enrolled, and the keys
cannot be enrolled before the system is installed. Enabling it is therefore a
deliberate sequence, with a known-good unsigned system at each step:

1. Install and boot with `secureBoot.enable = false`.
2. Run `sbctl create-keys`.
3. Put the firmware into Setup Mode. When dual-booting Windows, prefer an
   option that keeps the existing keys.
4. Run `sbctl enroll-keys --microsoft --firmware-builtin`. `--microsoft` keeps
   Windows and Microsoft-signed option ROMs bootable; `--firmware-builtin`
   keeps the firmware's own certificates.
5. Set `secureBoot.enable = true`, rebuild, enable Secure Boot in the firmware,
   and check `bootctl status` for `Secure Boot: enabled (user)`.

The full procedure, including how to make the EFI variables temporarily
mutable during enrollment, is in [Installing Asgard](/nix/getting-started/installation/#6-enroll-secure-boot-keys).
