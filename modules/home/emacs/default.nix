{
  config,
  inputs,
  lib,
  pkgs,
  settings,
  ...
}:
let
  tools = import ../editor-tools/packages.nix { inherit inputs pkgs; };
  runtime = tools ++ [
    pkgs.typescript-language-server
    pkgs.coreutils
    pkgs.diffutils
    pkgs.procps
    pkgs.git
    pkgs.jujutsu
    pkgs.lazygit
    pkgs.blazingjj
    config.programs.opencode.package
  ];
  grammars = pkgs.emacsPackages.treesit-grammars.with-all-grammars;
  # JSON strings are also valid Lisp strings, including escaping font names.
  string = builtins.toJSON;
  palette =
    colors:
    "'("
    + lib.concatStringsSep " " (lib.mapAttrsToList (name: value: "(${name} . ${string value})") colors)
    + ")";
in
{
  imports = [ ../editor-tools ];
  programs.emacs = {
    enable = true;
    # Keep EDITOR/VISUAL owned by Neovim while both editors are installed.
    package = pkgs.emacs;
    extraPackages =
      ep: with ep; [
        evil
        evil-collection
        evil-surround
        evil-commentary
        evil-args
        evil-matchit
        undo-fu
        undo-fu-session
        vertico
        orderless
        marginalia
        consult
        embark
        embark-consult
        corfu
        cape
        yasnippet
        yasnippet-capf
        apheleia
        lsp-mode
        consult-lsp
        dape
        agent-shell
        treemacs
        treemacs-evil
        magit
        diff-hl
        blamer
        eat
        breadcrumb
        auto-dark
        highlight-indent-guides
        hl-todo
        rainbow-mode
        imenu-list
        markdown-mode
        lua-mode
        nix-mode
        php-mode
        yaml-mode
        web-mode
        emmet-mode
        pug-mode
        sass-mode
        dtrt-indent
        treesit-fold
      ];
  };

  xdg.configFile."emacs/init.el".source = ./configs/init.el;
  xdg.configFile."emacs/early-init.el".source = ./configs/early-init.el;
  xdg.configFile."emacs/lisp".source = ./configs/lisp;
  xdg.configFile."emacs/nix-settings.el".text = ''
    ;;; nix-settings.el --- Generated settings -*- lexical-binding: t; -*-
    (setq exec-path (append '${
      "(" + lib.concatMapStringsSep " " (p: string "${p}/bin") runtime + ")"
    } exec-path))
    (setenv "PATH" (concat ${string (lib.makeBinPath runtime)} path-separator (getenv "PATH")))
    (setq treesit-extra-load-path '("${grammars}/lib"))
    (setq config-font ${string settings.fonts.mono}
          config-lua-libraries ["${pkgs.neovim-unwrapped}/share/nvim/runtime/lua"
                                "${pkgs.vimPlugins.luvit-meta}/library"]
          config-font-height ${toString (settings.fonts.terminalSize * 10)}
          config-theme-light ${palette settings.theme.light}
          config-theme-dark ${palette settings.theme.dark}
          config-bashdb-directory "${pkgs.bashdb}/share/bashdb"
          config-bash-executable "${pkgs.bash}/bin/bash"
          config-cat-executable "${pkgs.coreutils}/bin/cat"
          config-mkfifo-executable "${pkgs.coreutils}/bin/mkfifo"
          config-pkill-executable "${pkgs.procps}/bin/pkill")
  '';
}
