# Karabiner-Elements

This module manages only `~/.config/karabiner/karabiner.json`. Install
Karabiner-Elements with its official macOS installer before applying a profile
that imports this module.

Home Manager cannot install Karabiner's root-owned support files, system
LaunchDaemons, or DriverKit system extension. Adding `pkgs.karabiner-elements`
to `home.packages` installs the GUI applications but does not produce a complete
working installation.
