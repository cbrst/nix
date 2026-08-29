{ ... }:
{
  programs.ssh = {
    enable = true;
    includes = [ "~/.ssh/hosts" ];
  };
}
