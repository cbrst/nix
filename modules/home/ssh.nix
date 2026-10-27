{ pkgs, ... }:
{
  home.packages = [ pkgs.mosh ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/hosts" ];

    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 15;
      ServerAliveCountMax = 3;
    };
  };
}
