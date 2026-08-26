# Replace this whole file with /etc/nixos/hardware-configuration.nix from the
# target machine. It describes disks and hardware, so it cannot be shared.
{ pkgs, ... }:
{
  hardware.firmware = [
    pkgs.linux-firmware
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.initrd.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c2271f7c-ea42-4dbf-b644-28deade854f5";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd"
    ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/c2271f7c-ea42-4dbf-b644-28deade854f5";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd"
    ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/c2271f7c-ea42-4dbf-b644-28deade854f5";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
    ];
  };
  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/c2271f7c-ea42-4dbf-b644-28deade854f5";
    fsType = "btrfs";
    options = [
      "subvol=@log"
      "compress=zstd"
    ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0155-1CB0";
    fsType = "vfat";
  };
}
