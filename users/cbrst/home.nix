{ pkgs, ... }:
{
  # Set this to the Home Manager release used when this user's configuration
  # was first created. Do not change it merely when upgrading packages.
  home.stateVersion = "26.05";

  # Let Home Manager manage itself as part of this user's configuration.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    commit-mono
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
      "CommitMono"
      "JetBrainsMono Nerd Font"
      ];
    };
  };
}
