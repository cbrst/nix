{ ... }:
{
  # A small common command-line environment for any user machine.
  imports = [
    ../../modules/home/shell
    ../../modules/home/git.nix
  ];
}
