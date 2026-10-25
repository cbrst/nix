{
  lib,
  settings,
  pkgs,
  ...
}:
let
  # Ghostty theme files generated from the shared flake palette.
  themeFile =
    variant:
    let
      colors = settings.theme.${variant};
      terminal = settings.theme.terminal.${variant};
    in
    lib.concatStringsSep "\n" (
      lib.imap0 (index: color: "palette = ${toString index}=${color}") terminal.palette
      ++ [
        "background = ${colors.background}"
        "foreground = ${colors.foreground}"
        "cursor-color = ${terminal.cursor}"
        "cursor-text = ${terminal.cursorText}"
        "selection-background = ${terminal.selectionBackground}"
        "selection-foreground = ${terminal.selectionForeground}"
        "split-divider-color = ${colors.border}"
      ]
    )
    + "\n";
in
{
  # home.packages = [ pkgs.ghostty ];
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    settings = {
      shell-integration-features = "ssh-env,ssh-terminfo";
      font-family = settings.fonts.mono;
      font-size = settings.fonts.terminalSize;
      font-feature = "ss01";
      env = "CONFIG_POWERLINE_GLYPHS=1";
      adjust-cursor-thickness = 2;
      # adjust-cell-height = "10%";
      # adjust-font-baseline = "10%";
      unfocused-split-opacity = 0.5;
      mouse-hide-while-typing = true;
      window-padding-x = 2;
      window-padding-y = 2;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-theme = "ghostty";
      macos-titlebar-style = "transparent"; # "tabs" titlebar is buggy in 1.3.1 on Golden Gate
      gtk-titlebar = false;
      theme = "light:flake-light,dark:flake-dark";
      config-file = "?config-custom";
    };
  };

  xdg.configFile."ghostty/themes/flake-light".text = themeFile "light";
  xdg.configFile."ghostty/themes/flake-dark".text = themeFile "dark";
}
