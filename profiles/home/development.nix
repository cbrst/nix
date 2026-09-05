{ ... }:
{
  # Start with the minimal environment, then add development-specific tools.
  imports = [
    ./minimal.nix
    ../../modules/home/code
    ../../modules/home/neovim
    ../../modules/home/ai
    ../../modules/home/direnv.nix
  ];
}
