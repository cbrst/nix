{
  defaultSettings,
  lib,
  pkgs,
  ...
}:
{
  # Keep machine-specific settings next to the rest of this host's configuration.
  _module.args.settings = lib.recursiveUpdate defaultSettings {
    fonts.terminalSize = 14;
  };

  # Home Manager modules and profiles can be shared with Linux and NixOS.
  imports = [
    ../../profiles/home/desktop-macos.nix
    ../../profiles/home/development.nix
  ];

  # Keep operating-system differences at the host boundary.
  home.packages = [
    pkgs.terminal-notifier
  ];
}
