# Typed feature switches for the Neovim editor.
#
# This module only declares options; it has no `config`. Two places evaluate it:
# `default.nix` imports it into Home Manager, so hosts set
# `editor.neovim.features.*`; `package.nix` evaluates it on its own with
# `lib.evalModules`, so standalone packages get the same defaults and type
# checks. `spec.nix` turns the resolved values into plugins and tools, and a
# generated `init6.generated.features` Lua module tells the configuration what
# is present.
{ lib, ... }:
let
  # Must match the attribute names of `languages` in `tools.nix`; `spec.nix`
  # asserts this.
  languages = {
    lua = "Lua: lua-language-server and StyLua";
    markdown = "Markdown: rumdl and mdsf";
    nix = "Nix: nil and nixd";
    php = "PHP: Phpactor, Mago and html-beautify";
    python = "Python: Zuban and Ruff";
    shell = "Shell: bash-language-server, zshcs, Shellharden and shfmt";
    web = "Web: TypeScript (vtsls, nvim-vtsls), Emmet, Some Sass, HTML/CSS/JSON servers, tag auto-closing, oxlint and oxfmt";
    yaml = "YAML: yaml-language-server and yamlfmt";
  };

  enabledByDefault = description: lib.mkEnableOption description // { default = true; };
in
{
  options.editor.neovim.features = {
    ai.enable = enabledByDefault "claudecode.nvim and the Claude Code CLI";

    debug.enable = enabledByDefault "nvim-dap, its UI, virtual text, and the debug adapters";

    grammars = lib.mkOption {
      type = with lib.types; either (enum [ "all" ]) (listOf str);
      default = "all";
      example = [
        "bash"
        "lua"
        "markdown"
        "markdown_inline"
        "nix"
      ];
      description = ''
        Treesitter grammars to install: "all" for every grammar in nixpkgs, or
        a list of names from `vimPlugins.nvim-treesitter.builtGrammars`.
        Neovim bundles c, lua, markdown, markdown_inline, query, vim and vimdoc
        parsers of its own; filetypes without a parser fall back to regex
        syntax highlighting.
      '';
    };

    languages = lib.mapAttrs (_: description: {
      enable = enabledByDefault "${description}, plus the matching LSP setup and Conform formatters";
    }) languages;
  };
}
