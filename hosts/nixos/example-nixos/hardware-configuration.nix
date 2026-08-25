# Replace this whole file with /etc/nixos/hardware-configuration.nix from the
# target machine. It describes disks and hardware, so it cannot be shared.
{ ... }:
{
  # These placeholder values let `nix flake check` evaluate the example. They
  # are not safe to apply: use the installer-generated file for real disks.
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "ext4";
  };
}
