{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/hosts" ];

    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
    };
  };
}
