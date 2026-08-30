{
  config,
  configLib,
  lib,
  pkgs,
  settings,
  ...
}:
let
  fzfPreview = pkgs.writeShellApplication {
    name = "fzf-preview";
    runtimeInputs = [
      pkgs.bat
      pkgs.coreutils
      pkgs.eza
    ];

    text = ''
      path=$1
      if test -d "$path"; then
        eza --tree --color=always --icons=always --git "$path" | head -200
      else
        bat -p --color=always "$path"
      fi
    '';
  };

  zshAutocomplete = pkgs.zsh-autocomplete.overrideAttrs (old: {
    installPhase = old.installPhase + ''
      install -D ${
        pkgs.fetchFromGitHub {
          owner = "marlonrichert";
          repo = "zasync";
          rev = "5370537de80670b4a97e49cd253d15067709c0a6";
          hash = "sha256-tPosFoZSaUShaRpv7ca9BdOMREfmhnzjd/VKHSshhXo=";
        }
      }/z-async $out/share/zsh-autocomplete/z-async/z-async
    '';
  });
in
{
  home.packages = [
    pkgs.jq
    pkgs.doggo
    zshAutocomplete
    fzfPreview
  ];

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
    # zsh-autocomplete initializes the completion system itself.
    enableCompletion = false;
    syntaxHighlighting = {
      enable = true;
    };
    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        fpath+=($ZDOTDIR/functions)
        autoload -Uz $ZDOTDIR/functions/*(.:t)
      '')
      (lib.mkOrder 600 ''
        source ${zshAutocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
      '')
      (lib.mkOrder 1001 (builtins.readFile ./configs/zsh/zstyle.zsh))
      (lib.mkOrder 1002 (builtins.readFile ./configs/zsh/aliases.zsh))
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
    "@light-muted@" = settings.theme.light.muted;
    "@dark-path@" = settings.theme.dark.shade4;
    "@dark-vcs@" = settings.theme.dark.shade3;
    "@dark-muted@" = settings.theme.dark.muted;
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
