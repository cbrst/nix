# Hosts

A host is one specific computer, such as a laptop, workstation, server, or Mac.
Host files should stay small: they select profiles and supply values that cannot
be shared, such as a hostname, CPU architecture, home-directory path, or
hardware configuration.

Do not implement reusable features here. Put a feature in `../modules`, bundle
it in `../profiles`, then import the profile from the appropriate host.

- `nixos/` contains system-level NixOS hosts.
- `home/` contains standalone Home Manager hosts for generic Linux and macOS.

`flake.nix` turns each host into a named output that can be selected with
`--flake .#name`.
