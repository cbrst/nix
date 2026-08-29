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
        accent2 = "#6a2c96";
        accent3 = "#187a8b";
        accent4 = "#a34414";
        accent5 = "#917112";
        error = "#a11717";
        warning = "#917112";
        success = "#1f7a3d";
        info = "#25659d";
        faint = "#9c948b";
        added = "#1f7a3d";
        removed = "#a11717";
        changed = "#25659d";
        diffHighlightAdded = "#2aa252";
        diffHighlightRemoved = "#c41c1c";
        diffAddedBg = "#d2e0d1";
        diffRemovedBg = "#e9ceca";
        diffContextBg = "#d3dce2";
        syntaxKeyword = "#187a8b";
        syntaxFunction = "#911256";
        syntaxString = "#917112";
        syntaxNumber = "#b85c2e";
        syntaxType = "#6a2c96";
        syntaxOperator = "#9c948b";
        syntaxPunctuation = "#9c948b";
        shade0 = "#fffdf8";
        shade1 = "#f9f6f1";
        shade2 = "#f0edea";
        shade3 = "#e8e6e2";
        shade4 = "#dbd9d6";
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
        accent2 = "#cca6e7";
        accent3 = "#96d8e3";
        accent4 = "#e3b096";
        accent5 = "#dfd286";
        error = "#e99696";
        warning = "#dfd286";
        success = "#98cdaa";
        info = "#96bddf";
        faint = "#85807a";
        added = "#98cdaa";
        removed = "#e99696";
        changed = "#96bddf";
        diffHighlightAdded = "#badec6";
        diffHighlightRemoved = "#f0b7b7";
        diffAddedBg = "#2e3731";
        diffRemovedBg = "#3d2d2d";
        diffContextBg = "#2e343a";
        syntaxKeyword = "#96d8e3";
        syntaxFunction = "#eaa4c9";
        syntaxString = "#dfd286";
        syntaxNumber = "#dfa486";
        syntaxType = "#cca6e7";
        syntaxOperator = "#85807a";
        syntaxPunctuation = "#85807a";
        shade0 = "#100f0f";
        shade1 = "#171616";
        shade2 = "#201f1d";
        shade3 = "#282625";
        shade4 = "#353331";
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
        accent2 = "#B35B79";
        accent3 = "#597B75";
        accent4 = "#CC6D00";
        accent5 = "#77713F";
        error = "#E82424";
        warning = "#E98A00";
        success = "#6F894E";
        info = "#5A7785";
        faint = "#4E8CA2";
        added = "#6E915F";
        removed = "#D7474B";
        changed = "#DE9800";
        diffHighlightAdded = "#6E915F";
        diffHighlightRemoved = "#D7474B";
        diffAddedBg = "#B7D0AE";
        diffRemovedBg = "#D9A594";
        diffContextBg = "#D7E3D8";
        syntaxKeyword = "#624C83";
        syntaxFunction = "#4D699B";
        syntaxString = "#6F894E";
        syntaxNumber = "#B35B79";
        syntaxType = "#597B75";
        syntaxOperator = "#836F4A";
        syntaxPunctuation = "#4E8CA2";
        shade0 = "#FBF5C7";
        shade1 = "#F2ECBC";
        shade2 = "#E7E1AD";
        shade3 = "#DBD59E";
        shade4 = "#BDB783";
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
        accent2 = "#D27E99";
        accent3 = "#7FB4CA";
        accent4 = "#E46876";
        accent5 = "#FFA066";
        error = "#E82424";
        warning = "#FF9E3B";
        success = "#98BB6C";
        info = "#658594";
        faint = "#9CABCA";
        added = "#76946A";
        removed = "#C34043";
        changed = "#DCA561";
        diffHighlightAdded = "#98BB6C";
        diffHighlightRemoved = "#E82424";
        diffAddedBg = "#2B3328";
        diffRemovedBg = "#43242B";
        diffContextBg = "#252535";
        syntaxKeyword = "#957FB8";
        syntaxFunction = "#7E9CD8";
        syntaxString = "#98BB6C";
        syntaxNumber = "#D27E99";
        syntaxType = "#7AA89F";
        syntaxOperator = "#C0A36E";
        syntaxPunctuation = "#9CABCA";
        shade0 = "#16161D";
        shade1 = "#1F1F28";
        shade2 = "#2A2A37";
        shade3 = "#363646";
        shade4 = "#54546D";
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
