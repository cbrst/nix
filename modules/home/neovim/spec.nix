# The Neovim editor definition shared by every consumer of this flake.
#
# This is a plain function, not a module: it receives its dependencies as
# arguments and returns the pieces a wrapper needs. The Home Manager module in
# `default.nix` feeds them into `programs.neovim`; the standalone flake package
# in `package.nix` feeds the same pieces into `wrapNeovimUnstable`, so the
# plugin and tool lists exist exactly once.
{
  pkgs,
  lib,
  inputs,
  # Resolved host settings; only `settings.theme` is read here.
  settings,
  # Resolved `editor.neovim.features` values from `options.nix`.
  features,
  # The Claude Code CLI started by claudecode.nvim. Home Manager passes its
  # configured `programs.claude-code.finalPackage`; other consumers can pass
  # `pkgs.claude-code`.
  claudeCode,
}:
let
  # Grouped executables; see `tools.nix`.
  tools = import ./tools.nix { inherit inputs pkgs; };

  enabledLanguages = lib.filterAttrs (_: language: language.enable) features.languages;
  languageEnabled = name: features.languages.${name}.enable;

  # The language list in `options.nix` and the groups in `tools.nix` must
  # describe the same families, or a toggle would silently do nothing.
  checkedLanguages =
    let
      declared = lib.attrNames features.languages;
      provided = lib.attrNames tools.languages;
    in
    lib.throwIfNot (declared == provided)
      "neovim: options.nix languages (${toString declared}) differ from tools.nix languages (${toString provided})"
      enabledLanguages;

  # Feature flags for the Lua configuration, read through `init6.config.features`.
  init6Features = pkgs.vimUtils.buildVimPlugin {
    pname = "init6-features";
    version = "0";
    src = pkgs.writeTextDir "lua/init6/generated/features.lua" ''
      return ${
        lib.generators.toLua { } {
          ai = features.ai.enable;
          debug = features.debug.enable;
          languages = lib.mapAttrs (_: language: language.enable) features.languages;
        }
      }
    '';
  };

  dashboardPokemon = pkgs.writeShellApplication {
    name = "dashboard-pokemon";
    runtimeInputs = [
      pkgs.gnused
      pkgs.pokemon-colorscripts
    ];
    text = builtins.readFile ./scripts/dashboard-pokemon;
  };
  codedocs = pkgs.vimUtils.buildVimPlugin {
    pname = "codedocs";
    version = "0.6.0";
    src = pkgs.fetchzip {
      url = "https://github.com/jeangiraldoo/codedocs.nvim/archive/refs/tags/v0.6.0.tar.gz";
      hash = "sha256-aoYhVUSmjri2R3qH+9Js9YffSs8aLxlOL9NCCEzZICQ=";
      stripRoot = true;
    };
  };
  # The shared flake palette as a Lua module for the `init6` colorscheme.
  init6Palette = pkgs.vimUtils.buildVimPlugin {
    pname = "init6-palette";
    version = "0";
    src = pkgs.writeTextDir "lua/init6/generated/palette.lua" ''
      return ${
        lib.generators.toLua { } {
          inherit (settings.theme) light dark terminal;
        }
      }
    '';
  };
  neojjNvim = pkgs.vimUtils.buildVimPlugin {
    pname = "neojj";
    version = "1.8.0";
    dependencies = [ pkgs.vimPlugins.plenary-nvim ];
    # Diffview is optional and disabled in the Lua configuration.
    nvimSkipModules = [ "neojj.integrations.diffview" ];
    src = pkgs.fetchzip {
      url = "https://github.com/NicholasZolton/neojj/archive/d84589a265c44b5183887a43a456fe14550c0b56.tar.gz";
      hash = "sha256-9gMM55aeHYfEkEEU3gFq9XqZG3sIMoL4zkDb71eRquE=";
      stripRoot = true;
    };
  };
  scssQueries = pkgs.vimPlugins.nvim-treesitter.builtGrammars.scss.associatedQuery;
  scssGrammar = pkgs.vimPlugins.nvim-treesitter.builtGrammars.scss.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      pkgs.nodejs
      pkgs.tree-sitter
    ];
    patches = (old.patches or [ ]) ++ [ ./patches/tree-sitter-scss-namespaces.patch ];
    preBuild = ''
      tree-sitter generate
    ''
    + (old.preBuild or "");
    postInstall = (old.postInstall or "") + ''
      rm -rf "$out/queries"
      mkdir "$out/queries"
      cp -LR "${scssQueries}/queries/scss" "$out/queries/scss"
    '';
  });
  builtGrammars = pkgs.vimPlugins.nvim-treesitter.builtGrammars;
  selectedGrammars =
    if features.grammars == "all" then
      pkgs.vimPlugins.nvim-treesitter.allGrammars
    else
      map (
        name:
        builtGrammars.${name}
          or (throw "neovim: unknown Treesitter grammar \"${name}\" in editor.neovim.features.grammars")
      ) features.grammars;
  nvimTreesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    _:
    map (grammar: if grammar.pname == "tree-sitter-scss" then scssGrammar else grammar) selectedGrammars
  );
  neotree-file-nesting-config = pkgs.vimUtils.buildVimPlugin {
    pname = "neotree-file-nesting-config";
    version = "unstable-2025-03-06";
    src = pkgs.fetchzip {
      url = "https://github.com/saifulapm/neotree-file-nesting-config/archive/089adb6d3e478771f4485be96128796fb01a20c4.tar.gz";
      hash = "sha256-VCwujwpiRR8+MLcLgTWsQe+y0+BYL9HRZD+OzafNGGA=";
      stripRoot = true;
    };
  };
in
{
  # Unwrapped Neovim; each consumer wraps it with the plugins and PATH below.
  package = pkgs.neovim-unwrapped;

  # Executables placed on the wrapped editor's PATH: LSP servers, formatters,
  # debug adapters and the helpers the Lua configuration calls. The order only
  # matters when two packages ship the same command, and none currently do.
  # A package listed by several enabled language groups appears once.
  extraPackages = lib.unique (
    tools.core
    ++ tools.runtimes
    ++ lib.optionals features.debug.enable tools.debug
    ++ lib.concatLists (lib.attrValues (lib.intersectAttrs checkedLanguages tools.languages))
    ++ lib.optional features.ai.enable claudeCode
    ++ [
      # Random, centred sprite in the snacks.dashboard start screen.
      dashboardPokemon
    ]
  );

  # Every plugin and Treesitter grammar; nothing is installed at runtime.
  # Feature-specific plugins are appended below.
  plugins =
    with pkgs.vimPlugins;
    [
      auto-dark-mode-nvim
      # avante-nvim
      blink-cmp
      codedocs
      conform-nvim
      diffs-nvim
      dropbar-nvim
      fidget-nvim
      init6Features
      init6Palette
      gitsigns-nvim
      heirline-nvim
      lazydev-nvim
      luasnip
      luvit-meta
      mini-nvim
      neogit
      neojjNvim
      neo-tree-nvim
      neotree-file-nesting-config
      nui-nvim
      nvim-highlight-colors
      nvim-lspconfig
      # Grammars follow `editor.neovim.features.grammars`.
      nvimTreesitter
      outline-nvim
      overseer-nvim
      plenary-nvim
      render-markdown-nvim
      snacks-nvim
      telescope-fzf-native-nvim
      telescope-live-grep-args-nvim
      telescope-nvim
      telescope-ui-select-nvim
      todo-comments-nvim
      trouble-nvim
      vim-sleuth
      vim-tridactyl
      which-key-nvim
    ]
    ++ lib.optional features.ai.enable claudecode-nvim
    ++ lib.optionals features.debug.enable [
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      # Async library required by nvim-dap-ui.
      nvim-nio
      # `osv`, the adapter for debugging Neovim's own Lua.
      one-small-step-for-vimkind
    ]
    ++ lib.optional (languageEnabled "web") typescript-tools-nvim;

  # The Lua configuration: `init.lua`, `lua/` and `colors/`.
  configDir = ./configs;
}
