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

  noctalia = config.programs.noctalia.enable or false;

  fastfetchModules = [
    "break"
    {
      type = "title";
      format = "{#1;2}@{#0;1;39}{host-name}";
    }
    {
      type = "host";
      key = "{#0;90}├─ {#0;1;39}Host {#0;90}┬ {#0;32}{icon}";
    }
    {
      type = "cpu";
      key = "{#0;90}│       ├┬ {#0;32}{icon}";
    }
    {
      type = "memory";
      key = "{#0;90}│       │╰─ {#0;32}{icon}";
    }
    {
      type = "gpu";
      key = "{#0;90}│       ╰┬ {#0;32}{icon}";
    }
    {
      type = "display";
      key = "{#0;90}│        ╰─ {#0;32}{icon}";
      format = "{}×{}px {}hz";
    }
    {
      type = "os";
      key = "{#0;90}├─ {#0;1;39}OS {#0;90}──┬┬ {#0;33}{icon}";
    }
    {
      type = "kernel";
      key = "{#0;90}│       │╰─ {#0;33}{icon}";
    }
    {
      type = "wm";
      key = "{#0;90}│       ╰${if noctalia then "┬" else "─"} {#0;34}{icon}";
    }
  ]
  # Fastfetch detects neither a Quickshell desktop shell nor a prompt engine,
  # so their versions come from the packages this generation installs.
  ++ lib.optional noctalia {
    type = "custom";
    keyIcon = "";
    key = "{#0;90}│        ╰─ {#0;34}{icon}";
    format = "Noctalia ${config.programs.noctalia.package.version}";
  }
  ++ [
    {
      type = "terminal";
      keyIcon = "";
      key = "{#0;90}├─ {#0;1;39}Term {#0;90}┬ {#0;35}{icon}";
    }
    {
      type = "shell";
      keyIcon = "%_";
      paddingLeft = 0;
      key = "{#0;90}│       ├┬ {#0;35}{icon}";
    }
    {
      type = "custom";
      keyIcon = ">_";
      key = "{#0;90}│       │╰─ {#0;35}{icon}";
      paddingLeft = 0;
      format = "oh-my-posh ${config.programs.oh-my-posh.package.version}";
    }
    {
      type = "terminalfont";
      keyIcon = "󰛖";
      key = "{#0;90}│       ╰─ {#0;35}{icon}";
    }
    {
      type = "colors";
      key = "{#0;90}╰─ {#0;35}";
      paddingLeft = 0;
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

  # Each module prints one line, so the list length is the info height the
  # Pokémon logo is centred against. Extra GPUs or displays add lines.
  fastfetchPokemon = pkgs.writeShellApplication {
    name = "fastfetch-pokemon";
    runtimeInputs = [ pkgs.pokemon-colorscripts ];
    text = builtins.readFile ./scripts/fastfetch-pokemon;
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
        mkdir -p -- "''${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
        fpath+=($ZDOTDIR/functions)
        autoload -Uz $ZDOTDIR/functions/*(.:t)
      '')
      (lib.mkOrder 600 ''
        source ${zshAutocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
      '')
      (lib.mkOrder 1001 ''
        source ${./configs/zsh/poshcontext.zsh}
      '')
      (lib.mkOrder 1002 (builtins.readFile ./configs/zsh/zstyle.zsh))
      (lib.mkOrder 1003 (builtins.readFile ./configs/zsh/aliases.zsh))
      # Greet only the terminal's own shell. SHLVL cannot tell it apart, as
      # terminals can inherit a raised SHLVL from the desktop session; the
      # exported marker instead reaches nested shells and the Neovim
      # terminals started below this one.
      (lib.mkOrder 1500 ''
        if [[ -z $FASTFETCH_SHOWN && -z $NVIM && -t 1 ]]; then
          export FASTFETCH_SHOWN=1
          ${lib.getExe config.programs.fastfetch.package}
        fi
      '')
    ];
    # macOS updates restore /etc/zshrc and drop the Nix installer's hook, so
    # load the daemon environment from the user's own startup files instead.
    envExtra = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
      if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi
    '';
    # path_helper in /etc/zprofile moves system directories ahead of Nix in
    # login shells; put the Nix profiles back in front.
    profileExtra = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
      for profile in ''${(z)NIX_PROFILES}; do
        path=($profile/bin $path)
      done
      unset profile
      typeset -U path
    '';
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
        type = "command-raw";
        source = "${lib.getExe fastfetchPokemon} ${toString (builtins.length fastfetchModules)}";
        padding.left = 3;
      };
      modules = fastfetchModules;
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
    "@light-shade4@" = settings.theme.light.shade4;
    "@dark-path@" = settings.theme.dark.shade4;
    "@dark-vcs@" = settings.theme.dark.shade3;
    "@dark-muted@" = settings.theme.dark.muted;
    "@dark-shade4@" = settings.theme.dark.shade4;
  } ./configs/oh-my-posh/config.json;

  programs.pay-respects = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--alias"
      "fuck"
    ];
  };

  # Defaults live in shell aliases rather than RIPGREP_CONFIG_PATH, which
  # editors and scripts would inherit alongside their own explicit flags.
  programs.ripgrep.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Variables declared here are written into the user's shell environment.
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
