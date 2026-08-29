{ inputs, settings, ... }:
{
  # home.packages = [ pkgs.ghostty ];
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      shell-integration-features = "ssh-env,ssh-terminfo";
      font-family = settings.fonts.mono;
      font-size = 11;
      env = "CONFIG_POWERLINE_GLYPHS=1";
      adjust-cursor-thickness = 2;
      adjust-cell-height = "20%";
      adjust-font-baseline = "20%";
      unfocused-split-opacity = 0.5;
      mouse-hide-while-typing = true;
      window-padding-x = 2;
      window-padding-y = 2;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-theme = "ghostty";
      macos-titlebar-style = "tabs";
      gtk-titlebar = false;
      theme = "light:${settings.theme.apps.ghostty.light},dark:${settings.theme.apps.ghostty.dark}";
    };
  };

  xdg.configFile."ghostty/themes/meowsoot".source = "${inputs.meowsoot}/extras/ghostty/meowsoot";
  xdg.configFile."ghostty/themes/meowsoot-dawn".source =
    "${inputs.meowsoot}/extras/ghostty/meowsoot-dawn";
  xdg.configFile."ghostty/themes/kanagawa-lotus".source =
    "${inputs.kanagawa}/extras/ghostty/kanagawa-lotus";
  xdg.configFile."ghostty/themes/kanagawa-wave".source =
    "${inputs.kanagawa}/extras/ghostty/kanagawa-wave";
}
