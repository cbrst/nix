{
  configLib,
  lib,
  settings,
  ...
}:
let
  inherit (settings.theme) terminal;
  hex = configLib.colors.stripHash;

  # Foot colour sections generated from the shared flake palette.
  colorsFor =
    variant:
    let
      colors = settings.theme.${variant};
      term = terminal.${variant};
    in
    {
      background = hex colors.background;
      foreground = hex colors.foreground;
      cursor = "${hex term.cursorText} ${hex term.cursor}";
      selection-foreground = hex term.selectionForeground;
      selection-background = hex term.selectionBackground;
    }
    // lib.listToAttrs (
      lib.imap0 (index: color: {
        name = if index < 8 then "regular${toString index}" else "bright${toString (index - 8)}";
        value = hex color;
      }) term.palette
    );
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=11";
        shell = "zsh";
        term = "xterm-256color";
        resize-by-cells = "no";
        line-height = "15";
      };
      colors-dark = colorsFor "dark";
      colors-light = colorsFor "light";
      csd = {
        preferred = "none";
      };
    };
  };
}
