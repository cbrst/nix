{ ... }:
{
  # Start with the minimal environment, then add development-specific tools.
  imports = [
    ../../modules/home/steam.nix
  ];
}
