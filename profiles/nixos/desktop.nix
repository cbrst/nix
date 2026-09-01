{ inputs, ... }:
{
  # 1password
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  # Import NixOS modules required by machines with this role.
  imports = [
    ../../modules/nixos/base.nix
    ../../modules/nixos/network.nix
    ../../modules/nixos/archives.nix
    ../../modules/nixos/nautilus.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/gtk.nix
    ../../modules/nixos/multimedia.nix
    ../../modules/nixos/niri.nix
    ../../modules/nixos/noctalia.nix
    ../../modules/nixos/noctalia-greeter.nix
    ../../modules/nixos/1password.nix
    ../../modules/nixos/pipewire.nix
  ];
}
