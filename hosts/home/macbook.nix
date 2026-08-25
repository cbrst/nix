{ pkgs, ... }:
{
  # Home Manager modules and profiles can be shared with Linux and NixOS.
  imports = [
    ../../profiles/home/development.nix
  ];

  # Keep operating-system differences at the host boundary.
  home.packages = [
    pkgs.terminal-notifier
  ];
}
