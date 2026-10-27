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
  # Deletes unused imports through oxlint's no-unused-vars suggestion fix,
  # leaving unused locals, parameters and functions alone. oxlint applies only
  # non-overlapping fixes per run, so adjacent imports need further passes.
  oxlintUnusedImports = pkgs.writeShellApplication {
    name = "oxlint-unused-imports";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.oxlint
    ];
    text = ''
      for _ in 1 2 3; do
        before=$(cksum < "$1")
        oxlint --fix-suggestions -A all -D no-unused-vars "$1" > /dev/null || true
        [ "$(cksum < "$1")" = "$before" ] && break
      done
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
# Executables for Neovim's PATH, grouped so `spec.nix` can select them from
# `editor.neovim.features`: `core` and `runtimes` always, `debug` with
# `debug.enable`, and each `languages.<name>` with its own toggle. The language
# names must match `options.nix`. A package may appear in several language
# groups when several families use it; `spec.nix` removes duplicates. The Lua
# configuration names the executables it calls in `config/lsp_servers.lua`,
# `plugins/smart/autoformat.lua`, and `plugins/debug/init.lua`.
with pkgs;
{
  # Search, previews, `:Man`, and remote mounts; needed whatever languages
  # are enabled. sshfs needs FUSE: NixOS provides fusermount, macOS needs
  # macFUSE installed outside Nix.
  core = [
    file
    man-db
    ripgrep
    sshfs
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
      # Conform's chains for the web filetypes, JSON, GraphQL, and TOML.
      oxfmt
      oxlint
      oxlintUnusedImports
      nur.repos.congee.some-sass-language-server
      # TypeScript and JavaScript server; bundles its own TypeScript.
      vtsls
      # HTML, CSS, and JSON servers.
      vscode-langservers-extracted
    ];
    yaml = [
      yaml-language-server
      yamlfmt
    ];
  };
}
