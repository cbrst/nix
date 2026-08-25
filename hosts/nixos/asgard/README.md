# Example NixOS Host

This is a template for one NixOS machine. Rename this directory and the matching
`nixosConfigurations.example-nixos` entry in `../../../flake.nix` together.

Replace `hardware-configuration.nix` with the file generated on the target NixOS
machine. The installer creates it with the disk, filesystem, and driver choices
required to boot that computer.
