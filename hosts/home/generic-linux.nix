{ defaultSettings, ... }:
{
  # Use the shared settings without machine-specific overrides.
  _module.args.settings = defaultSettings;

  # This host chooses a development-ready user environment for a Linux machine.
  imports = [
    ../../profiles/home/development.nix
  ];
}
