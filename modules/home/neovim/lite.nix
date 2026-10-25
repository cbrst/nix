# Feature overrides for `packages.<system>.nvim-lite`: a smaller standalone
# editor for quick edits on machines that are not set up with this flake.
# Same shape as `editor.neovim.features` in `options.nix`; anything not set
# here keeps its default.
{
  # The Claude CLI is large, and the standalone package cannot use the
  # Home Manager-configured one anyway.
  ai.enable = false;

  # Debug adapters and their Node-based wrappers.
  debug.enable = false;

  # Configuration, scripting, and VCS files rather than every language. Neovim
  # bundles c, lua, markdown, markdown_inline, query, vim, and vimdoc itself;
  # they are listed so the nvim-treesitter queries match the grammars.
  grammars = [
    "bash"
    "comment"
    "diff"
    "git_config"
    "git_rebase"
    "gitattributes"
    "gitcommit"
    "gitignore"
    "jjdescription"
    "json"
    "lua"
    "luadoc"
    "luap"
    "markdown"
    "markdown_inline"
    "nix"
    "printf"
    "query"
    "regex"
    "toml"
    "vim"
    "vimdoc"
    "yaml"
    "zsh"
  ];

  # Keep the tooling for editing configuration; drop project languages.
  languages = {
    php.enable = false;
    python.enable = false;
    web.enable = false;
  };
}
