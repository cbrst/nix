{
  inputs,
  pkgs,
  settings,
  ...
}:
let
  meowsootNvim = pkgs.vimUtils.buildVimPlugin {
    pname = "meowsoot.nvim";
    version = "unstable-2026-07-19";
    src = inputs.meowsoot;
  };
  kanagawaNvim = pkgs.vimUtils.buildVimPlugin {
    pname = "kanagawa.nvim";
    version = "unstable-2026-05-10";
    src = inputs.kanagawa;
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

    extraPackages = import ../editor-tools/packages.nix { inherit inputs pkgs; };

    plugins = with pkgs.vimPlugins; [
      auto-dark-mode-nvim
      avante-nvim
      blink-cmp
      conform-nvim
      dropbar-nvim
      fidget-nvim
      gitsigns-nvim
      heirline-nvim
      lazydev-nvim
      luasnip
      luvit-meta
      mini-nvim
      monokai-pro-nvim
      meowsootNvim
      kanagawaNvim
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

  home.sessionVariables.CONFIG_THEME_FAMILY = settings.theme.family;
}
