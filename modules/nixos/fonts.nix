{ pkgs, settings, ... }:
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
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
        "Noto Sans"
        "Noto Color Emoji"
      ];
      serif = [
        "Noto Serif"
        "Noto Color Emoji"
      ];
      monospace = [
        settings.fonts.mono
        "Noto Sans Mono"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
}
