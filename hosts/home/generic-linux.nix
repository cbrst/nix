{ ... }:
{
  # This host chooses a development-ready user environment for a Linux machine.
  imports = [
    ../../profiles/home/development.nix
  ];
}
