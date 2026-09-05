{ ... }:
{
  # A small common command-line environment for any user machine.
  imports = [
    ../../modules/home/shell
    ../../modules/home/ssh.nix
    ../../modules/home/vcs
    # ../../modules/home/bitwarden.nix
    ../../modules/home/1password.nix
  ];
}
