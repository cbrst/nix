{ ... }:
{
  # home.packages = [ pkgs.ghostty ];
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."ghostty".source = ./config;
}
