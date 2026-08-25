# Example User

Rename this directory for your own account. The same `home.nix` is used by the
example NixOS machine, generic Linux machine, and macOS machine.

The actual username and home-directory path are set at the flake-output
boundary, because they differ between `/home/name` on Linux and `/Users/name`
on macOS.
