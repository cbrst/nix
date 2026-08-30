{
  config,
  configLib,
  lib,
  pkgs,
  settings,
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

  programs.fastfetch = {
    enable = true;
    settings = {
      display = {
        separator = "  ";
      };
      logo = {
        type = "auto";
        source = "${./configs/logo.png}";
        width = 25;
        padding = {
          top = 1;
          left = 1;
        };
      };
      modules = [
        "break"
        {
          type = "title";
          format = "{#1}@{host-name}";
        }
        {
          type = "host";
          key = "{#}├┬ {#32}{icon}";
        }
        {
          type = "cpu";
          key = "{#}│├┬ {#32}{icon}";
        }
        {
          type = "memory";
          key = "{#}││╰─ {#32}{icon}";
        }
        {
          type = "gpu";
          key = "{#}│╰┬ {#32}{icon}";
        }
        {
          type = "display";
          key = "{#}│ ╰─ {#32}{icon}";
          format = "{}×{}px {}hz";
        }
        {
          type = "os";
          key = "{#}╰┬┬ {#33}{icon}";
        }
        {
          type = "kernel";
          key = "{#} │╰─ {#33}{icon}";
        }
        {
          type = "wm";
          key = "{#} ├─ {#34}{icon}";
        }
        {
          type = "terminal";
          key = "{#} ╰┬ {#35}{icon}";
        }
        {
          type = "shell";
          key = "{#}  ├─ {#35}{icon}";
        }
        {
          type = "terminalfont";
          key = "{#}  ╰─ {#35}{icon}";
        }
        {
          type = "colors";
          paddingLeft = 2;
          symbol = "circle";
          block = {
            range = [
              2
              4
            ];
          };
        }
        "break"
      ];
    };

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
  xdg.configFile."oh-my-posh/config.json".text = configLib.renderTemplate {
    "@light-path@" = settings.theme.light.shade4;
    "@light-vcs@" = settings.theme.light.shade3;
    "@dark-path@" = settings.theme.dark.shade4;
    "@dark-vcs@" = settings.theme.dark.shade3;
  } ./configs/oh-my-posh/config.json;

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
