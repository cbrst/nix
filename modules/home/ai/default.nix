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
in
{
  home.packages = [
    rtk
    serena
  ];

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    extraPackages = [
      pkgs.lua-language-server
      pkgs.nixd
    ];

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
      accent = themeColor "accent3";
      error = themeColor "error";
      warning = themeColor "warning";
      success = themeColor "success";
      info = themeColor "info";
      text = themeColor "foreground";
      textMuted = themeColor "muted";
      selectedListItemText = themeColor "accentForeground";
      background = "none";
      backgroundPanel = themeColor "shade2";
      backgroundElement = themeColor "shade3";
      backgroundMenu = themeColor "shade4";
      border = themeColor "border";
      borderActive = themeColor "accent";
      borderSubtle = themeColor "shade4";
      diffAdded = themeColor "added";
      diffRemoved = themeColor "removed";
      diffContext = themeColor "muted";
      diffHunkHeader = themeColor "changed";
      diffHighlightAdded = themeColor "diffHighlightAdded";
      diffHighlightRemoved = themeColor "diffHighlightRemoved";
      diffAddedBg = themeColor "diffAddedBg";
      diffRemovedBg = themeColor "diffRemovedBg";
      diffContextBg = themeColor "diffContextBg";
      diffLineNumber = themeColor "muted";
      diffAddedLineNumberBg = themeColor "diffAddedBg";
      diffRemovedLineNumberBg = themeColor "diffRemovedBg";
      markdownText = themeColor "foreground";
      markdownHeading = themeColor "accent";
      markdownLink = themeColor "link";
      markdownLinkText = themeColor "accent3";
      markdownCode = themeColor "syntaxString";
      markdownBlockQuote = themeColor "muted";
      markdownEmph = themeColor "warning";
      markdownStrong = themeColor "accent4";
      markdownHorizontalRule = themeColor "border";
      markdownListItem = themeColor "link";
      markdownListEnumeration = themeColor "accent3";
      markdownImage = themeColor "link";
      markdownImageText = themeColor "accent3";
      markdownCodeBlock = themeColor "foreground";
      syntaxComment = themeColor "muted";
      syntaxKeyword = themeColor "syntaxKeyword";
      syntaxFunction = themeColor "syntaxFunction";
      syntaxVariable = themeColor "foreground";
      syntaxString = themeColor "syntaxString";
      syntaxNumber = themeColor "syntaxNumber";
      syntaxType = themeColor "syntaxType";
      syntaxOperator = themeColor "syntaxOperator";
      syntaxPunctuation = themeColor "syntaxPunctuation";
      thinkingOpacity = 0.6;
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
