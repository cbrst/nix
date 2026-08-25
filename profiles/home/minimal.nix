{ ... }:
{
  # A small common command-line environment for any user machine.
  imports = [
    ../../modules/home/shell.nix
    ../../modules/home/git.nix
  ];
}
