{
  family ? "meowsoot",
}:
let
  themes = {
    meowsoot = {
      light = {
        background = "#f9f6f1";
        foreground = "#3c312a";
        muted = "#7e7063";
        border = "#b0998d";
        hover = "#f2eee9";
        selected = "#d7cac1";
        accent = "#911256";
        accentForeground = "#f9f6f1";
        link = "#25659d";
      };
      dark = {
        background = "#171616";
        foreground = "#e2e0df";
        muted = "#b1ada9";
        border = "#454240";
        hover = "#282625";
        selected = "#353331";
        accent = "#eaa4c9";
        accentForeground = "#171616";
        link = "#96bddf";
      };
      apps = {
        ghostty = {
          light = "meowsoot-dawn";
          dark = "meowsoot";
        };
        neovim = {
          light = "meowsoot-dawn";
          dark = "meowsoot";
        };
        vscodium = {
          light = "Meowsoot Dawn";
          dark = "Meowsoot Night";
        };
        gtk = {
          name = "Adwaita-dark";
          package = null;
        };
      };
      niri = {
        activeFrom = "#cba6f7";
        activeTo = "#89b4fa";
        inactive = "#45475a";
      };
    };

    kanagawa = {
      light = {
        background = "#f2ecbc";
        foreground = "#545464";
        muted = "#8a8980";
        border = "#716e61";
        hover = "#e5ddb0";
        selected = "#c7d7e0";
        accent = "#624c83";
        accentForeground = "#f2ecbc";
        link = "#4d699b";
      };
      dark = {
        background = "#1f1f28";
        foreground = "#dcd7ba";
        muted = "#727169";
        border = "#54546d";
        hover = "#2a2a37";
        selected = "#2d4f67";
        accent = "#957fb8";
        accentForeground = "#1f1f28";
        link = "#7e9cd8";
      };
      apps = {
        ghostty = {
          light = "kanagawa-lotus";
          dark = "kanagawa-wave";
        };
        neovim = {
          light = "kanagawa-lotus";
          dark = "kanagawa-wave";
        };
        vscodium = {
          light = "Kanagawa Lotus";
          dark = "Kanagawa Wave";
        };
        gtk = {
          name = "Kanagawa-BL-LB";
          package = "kanagawa-gtk-theme";
        };
      };
      niri = {
        activeFrom = "#7e9cd8";
        activeTo = "#957fb8";
        inactive = "#54546d";
      };
    };
  };
in
if builtins.hasAttr family themes then
  themes.${family} // { inherit family; }
else
  throw "Unknown theme family '${family}'"
