{
  config,
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

  agentPrompts = {
    dennis = builtins.readFile ./agents/dennis.md;
    writeCommitMessage = builtins.readFile ./agents/write-commit-msg.md;
  };

  themeColor = name: {
    dark = settings.theme.dark.${name};
    light = settings.theme.light.${name};
  };
in
{
  home.packages = [
    pkgs.playwright
    pkgs.playwright-test
    rtk
    serena
  ];

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    agents = {
      dennis = ''
        ---
        name: dennis
        description: Designs, implements, visually inspects, and iteratively improves polished web UIs
        model: inherit
        ---
        ${agentPrompts.dennis}
      '';
      write-commit-msg = ''
        ---
        name: write-commit-msg
        description: Writes a commit message from a supplied diff
        tools: []
        model: haiku
        permissionMode: dontAsk
        ---
        ${agentPrompts.writeCommitMessage}
      '';
    };
    skills = ./skills;

    context = ''
      ## Version control: jj first

      Many repos here are managed with Jujutsu (`jj`), often colocated with
      Git (so `git status` can show a detached HEAD — that is expected, not
      a problem to fix). Before running any git status/diff/commit/log
      command, check whether the repo is jj-managed (e.g. a `.jj` directory,
      or `jj status` succeeding) and prefer `jj` commands when it is. Load
      the `idiomatic-jj` skill up front in that case rather than falling
      back to git habits.
    '';

    hooks.rtk-rewrite = inputs.rtk-src + "/hooks/claude/rtk-rewrite.sh";

    settings = {
      effortLevel = "medium";
      hooks.PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "${config.programs.claude-code.configDir}/hooks/rtk-rewrite";
            }
          ];
        }
      ];
    };
  };

  programs.opencode = {
    enable = false;
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

    agents = {
      dennis = ''
        ---
        description: Designs, implements, visually inspects, and iteratively improves polished web UIs
        mode: primary
        ---
        ${agentPrompts.dennis}
      '';
      write-commit-msg = ''
        ---
        description: Writes a commit message for the currently staged files
        mode: primary
        hidden: true
        model: openai/gpt-5.6-luna
        permission:
          edit: deny
          bash: deny
        ---
        ${agentPrompts.writeCommitMessage}
      '';
    };
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
