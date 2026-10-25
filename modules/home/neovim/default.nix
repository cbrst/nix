{
  config,
  lib,
  inputs,
  pkgs,
  settings,
  ...
}:
let
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
  # The shared flake palette as a Lua module for the `flake` colorscheme.
  flakePalette = pkgs.vimUtils.buildVimPlugin {
    pname = "flake-palette";
    version = "0";
    src = pkgs.writeTextDir "lua/flake_palette.lua" ''
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
  nvimTreesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    _:
    map (
      grammar: if grammar.pname == "tree-sitter-scss" then scssGrammar else grammar
    ) pkgs.vimPlugins.nvim-treesitter.allGrammars
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
  imports = [ ../editor-tools ];
  # Install Neovim for the current Home Manager user.
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    # Keep optional language-provider defaults explicit across Home Manager
    # releases. Enable them later only if your Neovim configuration needs them.
    withPython3 = false;
    withRuby = false;

    extraPackages = (import ../editor-tools/packages.nix { inherit inputs pkgs; }) ++ [
      config.programs.claude-code.finalPackage
      # Random, centred sprite in the snacks.dashboard start screen.
      dashboardPokemon
    ];

    plugins = with pkgs.vimPlugins; [
      auto-dark-mode-nvim
      # avante-nvim
      blink-cmp
      claudecode-nvim
      codedocs
      conform-nvim
      diffs-nvim
      dropbar-nvim
      fidget-nvim
      flakePalette
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
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-lspconfig
      nvim-nio
      # TODO: I probably don't need ALL grammars
      nvimTreesitter
      outline-nvim
      one-small-step-for-vimkind
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
      typescript-tools-nvim
      vim-sleuth
      vim-tridactyl
      which-key-nvim
    ];
  };

  # `source` makes Home Manager link this repository file into the user's
  # configuration directory instead of copying and maintaining it manually.
  xdg.configFile."nvim/init.lua".source = ./configs/init.lua;
  xdg.configFile."nvim/lua".source = ./configs/lua;
  xdg.configFile."nvim/colors".source = ./configs/colors;
}
