{ inputs, pkgs }:
let
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
# Executables for Neovim's PATH, grouped so callers can select subsets.
# `spec.nix` currently concatenates every group. Each package belongs to
# exactly one group; the Lua configuration names the executables it calls in
# `config/lsp_servers.lua`, `plugins/smart/autoformat.lua`, and
# `plugins/debug/init.lua`.
with pkgs;
{
  # Search, previews, and `:Man`; needed whatever languages are enabled.
  core = [
    file
    man-db
    ripgrep
    tree-sitter
  ];

  # Interpreters. Debug configurations launch programs with them (python3,
  # node, bash, lua), Overseer tasks and terminals run them, and some language
  # tooling expects them on PATH. They stay available when `debug` is dropped.
  runtimes = [
    bash
    lua
    nodejs
    python3
    zsh
  ];

  # Debug adapters used only by `plugins/debug/`.
  debug = [
    bashdb
    bashDebugAdapter
    luaDebugAdapter
    python3Packages.debugpy
    vscode-js-debug
  ];

  # Language servers and formatters, one list per language family.
  languages = {
    lua = [
      lua-language-server
      stylua
    ];
    markdown = [
      mdsf
      rumdl
    ];
    nix = [
      nil
      nixd
    ];
    php = [
      # `html-beautify` is the first step of Conform's PHP chain.
      js-beautify
      mago
      phpactor
    ];
    python = [
      ruff
      zuban
    ];
    shell = [
      bash-language-server
      shellharden
      shfmt
      inputs.zshcs.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    web = [
      emmet-language-server
      prettier
      nur.repos.congee.some-sass-language-server
      # `tsserver` for typescript-tools.nvim.
      typescript_5
      # HTML, CSS, and JSON servers.
      vscode-langservers-extracted
    ];
    yaml = [ yaml-language-server ];
  };
}
