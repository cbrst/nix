# Install NixOS With This Flake

This guide follows the NixOS manual's manual-installation procedure, using the
Asgard configuration in this flake instead of creating `/etc/nixos` with
`nixos-generate-config`. It installs to a UEFI system that dual-boots Windows
and uses Limine with Secure Boot enabled only after the first successful NixOS
boot.

Do not run partitioning or formatting commands until you have confirmed the
target device and preserved every required Windows partition.

## Boot The Installation Medium

Boot the NixOS installation medium in UEFI mode. On a graphical image, open a
terminal. The installer logs in as `nixos`; become root and enable time
synchronization:

```bash
sudo -i
timedatectl set-ntp true
```

Confirm that the installer was booted in UEFI mode:

```bash
test -d /sys/firmware/efi && echo UEFI
```

## Connect To The Network

Verify the installer has network access before continuing:

```bash
ip address
ping -c 3 nixos.org
```

For Wi-Fi or other interactive NetworkManager configuration, use:

```bash
nmtui
```

## Partition And Format Storage

Asgard expects a Btrfs filesystem with these subvolumes:

```text
/        @
/home    @home
/nix     @nix
/var/log @log
/boot    EFI System Partition formatted as vfat
```

Inspect disks and partitions before making changes:

```bash
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS
blkid
```

Use a partitioning tool such as `cfdisk`, `fdisk`, or `parted` to create a Linux
partition in the free space. Keep the existing Windows partitions and EFI
System Partition. Do not continue until the selected Linux partition is
correct.

Format only the new Linux partition as Btrfs. Replace the placeholder with its
device path, not its UUID:

```bash
mkfs.btrfs -L nixos /dev/<linux-partition>
```

Identify the new filesystem UUID with `blkid`, then create the subvolumes:

```bash
mount /dev/disk/by-uuid/<linux-partition-uuid> /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
umount /mnt
```

Mount the target layout. Replace both UUID placeholders with the values reported
by `blkid`:

```bash
mount -o subvol=@,compress=zstd \
  /dev/disk/by-uuid/<linux-partition-uuid> /mnt
mkdir -p /mnt/home /mnt/nix /mnt/var/log /mnt/boot

mount -o subvol=@home,compress=zstd \
  /dev/disk/by-uuid/<linux-partition-uuid> /mnt/home
mount -o subvol=@nix,compress=zstd \
  /dev/disk/by-uuid/<linux-partition-uuid> /mnt/nix
mount -o subvol=@log,compress=zstd \
  /dev/disk/by-uuid/<linux-partition-uuid> /mnt/var/log
mount -o umask=077 /dev/disk/by-uuid/<esp-uuid> /mnt/boot
```

Do not format or overwrite the Windows EFI System Partition unless that is an
intentional decision. Limine can use the existing ESP when it has sufficient
space.

## Fetch The Configuration

Clone the flake into the target system so it remains available at
`/etc/nix-config` after the first boot:

```bash
mkdir -p /mnt/etc
git clone <repository-url> /mnt/etc/nix-config
```

For a private repository, use temporary installer credentials or a deploy key.
Do not put credentials in the flake.

## Configure The System

The manual normally uses `nixos-generate-config` to create the target
configuration. Do not run it here: this flake already provides the system
configuration. Instead, edit its Asgard hardware module to describe the target
machine and the filesystems mounted above:

```bash
$EDITOR /mnt/etc/nix-config/hosts/nixos/asgard/hardware-configuration.nix
```

Replace the Btrfs and EFI partition UUIDs in that file with the values reported
by `blkid`. Keep the filesystem mount points, Btrfs subvolume options, and
`/boot` EFI mount consistent with the mounted layout. Add `umask=077` to the
EFI filesystem options to match the installer mount. Add any machine-specific
settings needed to boot, such as required initrd modules, encrypted volumes,
swap, CPU microcode, or GPU support.

## Validate The Flake

From the installer, validate the configuration before installation. If the
configuration requires experimental Nix features, enable them in the invoking
Nix process as well as declaratively in the target configuration.

```bash
nix --extra-experimental-features ca-derivations \
  flake check /mnt/etc/nix-config
nix --extra-experimental-features ca-derivations \
  build /mnt/etc/nix-config#nixosConfigurations.asgard.config.system.build.toplevel
```

Confirm the evaluated user configuration contains the expected account details:

```bash
nix eval /mnt/etc/nix-config#nixosConfigurations.asgard.config.users.users.cbrst
```

## Install The First Generation

Keep firmware Secure Boot disabled, and keep this setting disabled for the
first installation:

```nix
boot.loader.limine.secureBoot.enable = false;
```

Install the flake:

```bash
nixos-install --flake /mnt/etc/nix-config#asgard
```

The installer prompts for the root password. After it completes, set the
password for the declared `cbrst` account before rebooting:

```bash
nixos-enter --root /mnt -c 'passwd cbrst'
```

Finish installation:

```bash
sync
umount -R /mnt
reboot
```

Remove the installation media and select the installed Limine entry.

## Verify The First Boot

Before enabling Secure Boot, verify that:

- Limine starts NixOS.
- The Noctalia Greeter lists `cbrst`.
- The configured password authenticates successfully.
- Niri starts as the selected session.
- Foot opens with `Mod+Return`.
- Firefox and Neovim are available.

Do not start Secure Boot enrollment until this unsigned system works normally.

## Enroll Secure Boot Keys

On the installed NixOS system, generate Secure Boot keys:

```bash
sudo sbctl create-keys
```

Reboot into UEFI firmware settings and enter Secure Boot Setup Mode. This may
be named "Reset to Setup Mode" or an equivalent option to clear custom Secure
Boot keys.

For dual boot with Windows, preserve Microsoft and firmware-builtin certificates
when enrollment is supported:

```bash
sudo sbctl enroll-keys --microsoft --firmware-builtin
```

Check enrollment status:

```bash
sudo sbctl status
```

## Enable Signed Limine

Change the Limine configuration to enable Secure Boot:

```nix
boot.loader.limine.secureBoot.enable = true;
```

Apply the new configuration:

```bash
sudo nixos-rebuild switch --flake /etc/nix-config#asgard
```

Enable Secure Boot in UEFI firmware if it was not enabled automatically, then
reboot. Verify the resulting state:

```bash
bootctl status
sudo sbctl verify
```

The firmware should report Secure Boot enabled in user mode, and `sbctl verify`
should report signed boot files.
