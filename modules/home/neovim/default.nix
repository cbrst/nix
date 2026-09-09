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
  neotree-file-nesting-config = pkgs.vimUtils.buildVimPlugin {
    pname = "neotree-file-nesting-config";
    version = "unstable-2025-03-06";
    src = pkgs.fetchzip {
      url = "https://github.com/saifulapm/neotree-file-nesting-config/archive/089adb6d3e478771f4485be96128796fb01a20c4.tar.gz";
      hash = "sha256-VCwujwpiRR8+MLcLgTWsQe+y0+BYL9HRZD+OzafNGGA=";
      stripRoot = true;
    };
  };
  bashDebugExtension = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "bash-debug";
      publisher = "rogalmic";
      version = "0.3.9";
      hash = "sha256-f8FUZCvz/PonqQP9RCNbyQLZPnN5Oce0Eezm/hD19Fg=";
    };
  };
  bashDebugAdapter = pkgs.writeShellApplication {
    name = "bash-debug-adapter";
    runtimeInputs = [ pkgs.nodejs ];
    text = ''
      exec node "${bashDebugExtension}/share/vscode/extensions/rogalmic.bash-debug/out/bashDebug.js" "$@"
    '';
  };
  luaDebugExtension = pkgs.vscode-extensions.tomblind.local-lua-debugger-vscode;
  luaDebugAdapter = pkgs.writeShellApplication {
    name = "local-lua-debug-adapter";
    runtimeInputs = [ pkgs.nodejs ];
    text = ''
      exec node "${luaDebugExtension}/share/vscode/extensions/tomblind.local-lua-debugger-vscode/extension/debugAdapter.js" "$@"
    '';
  };
in
{
  # Install Neovim for the current Home Manager user.
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    # Keep optional language-provider defaults explicit across Home Manager
    # releases. Enable them later only if your Neovim configuration needs them.
    withPython3 = false;
    withRuby = false;

    extraPackages = with pkgs; [
      bash
      bashdb
      bashDebugAdapter
      file
      lua
      luaDebugAdapter
      python3
      python3Packages.debugpy
      ripgrep
      vscode-js-debug

      # Language tools (conform & LSP)
      bash-language-server
      emmet-language-server
      js-beautify
      lua-language-server
      man-db
      mdsf
      nixd
      nil
      nodejs
      phpactor
      prettier
      ruff
      rumdl
      stylua
      shellharden
      shfmt
      tree-sitter
      typescript
      vscode-langservers-extracted
      yaml-language-server
      zsh
      inputs.zshcs.packages.${pkgs.stdenv.hostPlatform.system}.default
      zuban
    ];

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
      nvim-treesitter.withAllGrammars
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

  # Project-local rumdl and markdownlint configuration takes precedence over
  # this user-level fallback.
  xdg.configFile."rumdl/rumdl.toml".text = ''
    [MD013]
    line-length = 80
    reflow = true
    reflow-mode = "normalize"
    code-blocks = false
    tables = false
    headings = false
    math-blocks = false
  '';

  home.sessionVariables.CONFIG_THEME_FAMILY = settings.theme.family;
}
