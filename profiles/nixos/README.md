# NixOS Profiles

These profiles group NixOS-only modules into roles for complete operating
systems. Import one from a file under `hosts/nixos/`.

The example `desktop.nix` is intentionally small. Later it can import modules
for audio, graphics, printing, or desktop services without changing every host
that uses it.
