{ defaultSettings, pkgs, ... }:
{
  # Use the shared settings without machine-specific overrides.
  _module.args.settings = defaultSettings;

  # Home Manager modules and profiles can be shared with Linux and NixOS.
  imports = [
    ../../profiles/home/desktop-base.nix
    ../../profiles/home/development.nix
  ];

  # Keep operating-system differences at the host boundary.
  home.packages = [
    pkgs.terminal-notifier
  ];
}
