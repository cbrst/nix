{ ... }:
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
      csd = {
        preferred = "none";
      };
    };
  };
}
