{ pkgs, settings, ... }:
{
  fonts.packages = with pkgs; [
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    commit-mono
    nerd-fonts.jetbrains-mono
    geist-font
    _0xproto
    _0xpropo
  ];

  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting = {
      enable = true;
      style = "slight";
    };
    subpixel = {
      rgba = "none";
      lcdfilter = "default";
    };
    defaultFonts = {
      sansSerif = [
        settings.fonts.sans
        "Inter Display"
        "Inter"
        "Noto Sans"
        "Noto Color Emoji"
      ];
      serif = [
        "Noto Serif"
        "Noto Color Emoji"
      ];
      monospace = [
        settings.fonts.mono
        "CommitMono"
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
}
