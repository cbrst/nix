{ ... }:
{
  # Start with the minimal environment, then add development-specific tools.
  imports = [
    ./minimal.nix
    ../../modules/home/neovim
    ../../modules/ai
  ];
}
