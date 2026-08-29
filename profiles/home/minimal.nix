{ ... }:
{
  # A small common command-line environment for any user machine.
  imports = [
    ../../modules/home/shell
    ../../modules/home/ssh.nix
    ../../modules/home/git
    ../../modules/home/1password.nix
  ];
}
