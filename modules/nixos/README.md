# NixOS Modules

Put system-wide NixOS features here: services, networking, boot settings, users,
security, and hardware-related configuration. These modules do not work on
generic Linux or macOS because they use NixOS options.

Import a module from a NixOS profile, or directly from a NixOS host when it is
truly host-specific.

## Secure Boot

`secure-boot.nix` provides the sbctl utility, which allows for generating and
enrolling Secure Boot keys. Enabling Secure Boot is a multi-step process.

### Boot without secure boot

Temporarily use:

``` nix
boot.loader.limine = {
    enable = true;
    secureBoot.enable = false;
};
```

Rebuild the system:

``` sh
sudo nixos-rebuild switch --flake .#{host}
```

### Generate keys

Boot into the resulting system and run:

``` sh
sudo sbctl create-keys
```

This stores keys under:

`/var/lib/sbctl`

### Enter firmware Setup Mode

Reboot into UEFI firmware settings and choose something like:

- Reset Secure Boot to Setup Mode
- Erase Secure Boot keys
- Clear Secure Boot keys

Do not enable Secure Boot yet. The firmware must be in Setup Mode so custom
keys can be enrolled.

When there is an option to enable Setup Mode _without_ removing existing keys,
use it if you are installing alongside Windows. Otherwise you are going to have
a _Really Bad Time™_.

### Enroll keys

Boot back into NixOS and run:

```sh
sudo sbctl enroll-keys --microsoft --firmware-builtin
```

The `--microsoft` option is important for preserving compatibility with Windows
and Microsoft-signed hardware Option ROMs. `--firmware-builtin` preserves
firmware-provided certificates.

### Enable Limine Secure Boot

Change the configuration to:

```nix
boot.loader.limine = {
    enable = true;
    secureBoot.enable = true;
};
```

Then rebuild:

```sh
sudo nixos-rebuild switch --flake .#{host}
```

Limine will now use the keys managed by `sbctl` to sign the relevant boot
components.

### Enable Secure Boot

Reboot into UEFI settings and enable Secure Boot if the firmware did not enable
it automatically. Boot the machine and verify:

```sh
bootctl status
```

You should see something like:

`Secure Boot: enabled (user)`
