{
  inputs,
  pkgs,
  settings,
  ...
}:

let
  rtk = pkgs.callPackage ../../../packages/rtk {
    inherit inputs;
  };

  serena = inputs.serena.packages.${pkgs.stdenv.hostPlatform.system}.serena;

  themeColor = name: {
    dark = settings.theme.dark.${name};
    light = settings.theme.light.${name};
  };
  ansiColor = color: {
    dark = color;
    light = color;
  };
in
{
  home.packages = [
    rtk
    serena
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    extraPackages = [ pkgs.lua-language-server ];

    settings = {
      model = "openai/gpt-5.6-sol";
      autoupdate = false;
      compaction = {
        auto = true;
        prune = true;
        reserved = 10000;
      };
    };

    tui.theme = "config-theme";
    themes.config-theme.theme = {
      primary = themeColor "accent";
      secondary = themeColor "link";
      accent = ansiColor 6;
      error = ansiColor 1;
      warning = ansiColor 3;
      success = ansiColor 2;
      info = themeColor "link";
      text = themeColor "foreground";
      textMuted = themeColor "muted";
      background = themeColor "background";
      backgroundPanel = themeColor "hover";
      backgroundElement = themeColor "selected";
      border = themeColor "border";
      borderActive = themeColor "accent";
      borderSubtle = themeColor "hover";
      diffAdded = ansiColor 2;
      diffRemoved = ansiColor 1;
      diffContext = themeColor "muted";
      diffHunkHeader = themeColor "link";
      diffHighlightAdded = ansiColor 10;
      diffHighlightRemoved = ansiColor 9;
      diffAddedBg = themeColor "hover";
      diffRemovedBg = themeColor "hover";
      diffContextBg = themeColor "background";
      diffLineNumber = themeColor "muted";
      diffAddedLineNumberBg = themeColor "selected";
      diffRemovedLineNumberBg = themeColor "selected";
      markdownText = themeColor "foreground";
      markdownHeading = themeColor "accent";
      markdownLink = themeColor "link";
      markdownLinkText = ansiColor 6;
      markdownCode = ansiColor 2;
      markdownBlockQuote = themeColor "muted";
      markdownEmph = ansiColor 3;
      markdownStrong = themeColor "accent";
      markdownHorizontalRule = themeColor "border";
      markdownListItem = themeColor "link";
      markdownListEnumeration = ansiColor 6;
      markdownImage = themeColor "link";
      markdownImageText = ansiColor 6;
      markdownCodeBlock = themeColor "foreground";
      syntaxComment = themeColor "muted";
      syntaxKeyword = ansiColor 6;
      syntaxFunction = themeColor "accent";
      syntaxVariable = themeColor "foreground";
      syntaxString = ansiColor 3;
      syntaxNumber = ansiColor 5;
      syntaxType = themeColor "link";
      syntaxOperator = ansiColor 6;
      syntaxPunctuation = themeColor "foreground";
    };

    agents = ./agents;
    skills = ./skills;
  };

  programs.mcp = {
    enable = true;

    servers.serena = {
      command = "${serena}/bin/serena";

      args = [
        "start-mcp-server"
        "--transport"
        "stdio"
        "--context"
        "ide"
        "--project-from-cwd"
        "--open-web-dashboard=false"
      ];
    };
  };

  # RTK's native OpenCode integration.
  #
  # This is the exact plugin normally installed by:
  #
  #   rtk init --global --opencode
  #
  # but Home Manager owns it instead.
  xdg.configFile."opencode/plugins/rtk.ts".source = "${inputs.rtk-src}/hooks/opencode/rtk.ts";
}
