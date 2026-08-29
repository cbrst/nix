{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.jq ];

  # Home Manager installs and configures Zsh for this user.
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };
    defaultKeymap = "viins";
    dirHashes = {
      nix = "/etc/nix-config";
      p = "${config.home.homeDirectory}/Projects";
    };
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    fastSyntaxHighlighting = {
      enable = true;
    };
    initContent =
      let
        zshBefore = lib.mkBefore ''
          fpath+=($ZDOTDIR/functions)
          autoload -Uz $ZDOTDIR/functions/*(.:t)
        '';
        zshAfter = lib.mkAfter ''
          source $ZDOTDIR/aliases.zsh
        '';
      in
      lib.mkMerge [
        zshBefore
        zshAfter
      ];
    history = {
      append = true;
      expireDuplicatesFirst = true;
      ignoreAllDups = true;
      save = 2000;
      share = true;
    };
  };
  xdg.configFile."zsh/functions".source = ./configs/zsh/functions;
  xdg.configFile."zsh/aliases.zsh".source = ./configs/zsh/aliases.zsh;

  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
      batwatch
    ];
  };

  programs.eza = {
    enable = true;
    colors = "auto";
    enableZshIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "--git"
      "--header"
      "--icons=always"
    ];
  };

  # TODO: Needs preview
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--height 50%"
      "--layout reverse"
      "--color border:7,pointer:6,hl:6,info:6,marker:2,fg+:1:bold,bg+:-1,hl+:6"
      "--prompt ' '"
      "--pointer ' '"
      "--marker ' '"
      "--info inline:'  '"
      "--bind 'ctrl-o:execute($\{EDITOR} {})+abort'"
    ];
    enableZshIntegration = true;
    fileWidget.options = [
      "--preview 'head {}'"
      "--bind 'ctrl-/:toggle-preview'"
    ];
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    configFile = "${config.xdg.configHome}/oh-my-posh/config.json";
  };
  xdg.configFile."oh-my-posh/config.json".source = ./configs/oh-my-posh/config.json;

  programs.zoxide = {
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = true;
  };

  # Variables declared here are written into the user's shell environment.
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
