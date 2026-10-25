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
with pkgs;
[
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
  bash-language-server
  emmet-language-server
  js-beautify
  lua-language-server
  mago
  man-db
  mdsf
  nixd
  nil
  nodejs
  phpactor
  prettier
  ruff
  rumdl
  nur.repos.congee.some-sass-language-server
  stylua
  shellharden
  shfmt
  tree-sitter
  typescript_5
  vscode-langservers-extracted
  yaml-language-server
  zsh
  inputs.zshcs.packages.${pkgs.stdenv.hostPlatform.system}.default
  zuban
]
