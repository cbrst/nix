# Neovim Module

This directory keeps the Neovim installation and its personal configuration
together.

## Layout

| Path | Role |
| --- | --- |
| `spec.nix` | The editor definition: unwrapped Neovim, every plugin and Treesitter grammar, the tools on `PATH`, and the Lua configuration directory |
| `tools.nix` | External executables on the editor's `PATH`, in named groups (see below) |
| `default.nix` | Home Manager module: feeds `spec.nix` into `programs.neovim`, links the configuration into `~/.config/nvim`, and writes the Mago/rumdl fallback configuration |
| `package.nix` | Standalone wrapper published as `packages.<system>.nvim` |
| `configs/` | `init.lua`, `lua/` and `colors/`; plain Lua, testable straight from the checkout |
| `scripts/` | Helper scripts packaged by `spec.nix`, such as the dashboard Pokémon |
| `patches/` | Source patches for packaged dependencies (the SCSS grammar) |

The development profile imports this module, so every host using that profile
receives the same editor setup.

## The editor definition

`spec.nix` is a plain function rather than a Home Manager module:

```nix
import ./spec.nix { inherit pkgs lib inputs settings; claudeCode = <package>; }
# => { package; extraPackages; plugins; configDir; }
```

Because it does not depend on Home Manager, two wrappers share it: `default.nix`
for Home Manager and `package.nix` for the standalone package. Home Manager-only
values are passed in as arguments. `claudeCode` is
`programs.claude-code.finalPackage` under Home Manager and `pkgs.claude-code` in
the standalone package.

To add something:

- a plugin or grammar: add it to `plugins` in `spec.nix`, then `require` it from
  the Lua configuration;
- a custom or pinned plugin: add a `buildVimPlugin` derivation in the `let`
  block of `spec.nix`, then list it in `plugins`;
- an LSP server, formatter, or debug adapter: add it to the matching group in
  `tools.nix`;
- a Home Manager-only value: add an argument to `spec.nix` and pass it from both
  `default.nix` and `package.nix`.

## Tool groups

`tools.nix` returns an attribute set of package lists instead of one flat list:

| Group | Contents | Used by |
| --- | --- | --- |
| `core` | `file`, `man-db`, `ripgrep`, `tree-sitter` | Pickers, previews, `:Man` |
| `runtimes` | `bash`, `lua`, `nodejs`, `python3`, `zsh` | Debug launches, Overseer tasks, terminals, language tooling |
| `debug` | bashdb and its adapter, the local Lua adapter, debugpy, vscode-js-debug | `plugins/debug/` |
| `languages.lua` | lua-language-server, StyLua | |
| `languages.markdown` | mdsf, rumdl | |
| `languages.nix` | nil, nixd | |
| `languages.php` | js-beautify (`html-beautify`), Mago, Phpactor | |
| `languages.python` | Ruff, Zuban | |
| `languages.shell` | bash-language-server, Shellharden, shfmt, zshcs | |
| `languages.web` | Emmet, Prettier, Some Sass, TypeScript (`tsserver`), vscode-langservers-extracted | |
| `languages.yaml` | yaml-language-server | |

`spec.nix` currently puts every group on `PATH`. The grouping is groundwork for
per-host options that drop groups a machine does not need. Two invariants keep
regrouping safe: each package belongs to exactly one group, and no two packages
ship a command with the same name, so the order of groups on `PATH` never
changes which executable runs. Interpreters live in `runtimes` rather than
`debug` because more than the debuggers use them.

Dropping a group is not yet free of side effects in Lua. `plugins/lsp/init.lua`
skips servers whose command is missing from `PATH`, but then warns about them on
every start ("Missing Home Manager LSP tools"). typescript-tools.nvim is set up
unconditionally and expects `tsserver`. The Lua side therefore needs to learn
which groups are enabled before options can remove them.

## Standalone editor

The flake publishes the same editor as `packages.<system>.nvim` for
`x86_64-linux` and `aarch64-darwin`. It runs on any machine with Nix (flakes
enabled), without Home Manager or this repository's activation:

```bash
nix run .#nvim -- file.txt                  # from a checkout
nix run github:cbrst/nix#nvim -- file.txt   # from anywhere
nix profile install github:cbrst/nix#nvim   # keep it installed
```

How it differs from the Home Manager editor:

- **Configuration** is bundled in the store and loaded through the wrapper's
  `-u` init file. `~/.config/nvim` is never read, so a machine's own Neovim
  configuration is unaffected. `vim.g.flake_config_dir` holds the bundled path;
  `<leader>fp` searches it.
- **State** lives under `NVIM_APPNAME=nvim-flake`, e.g.
  `~/.local/state/nvim-flake` and `~/.local/share/nvim-flake`, separate from any
  other Neovim. The wrapper only sets a default, so
  `NVIM_APPNAME=other nix run .#nvim` overrides it.
- **Theme and fonts** come from the flake's `defaultSettings`, not a host's
  overrides. The terminal must still provide a Nerd Font.
- **Claude Code** is plain `pkgs.claude-code`, without the plugins, skills and
  settings that `modules/home/ai/` configures. claudecode.nvim works, but the
  CLI uses whatever `~/.claude` the machine has.
- **Mago and rumdl fallbacks** are not written, because they are Home Manager
  files. Project-local configuration still applies.

The closure is large, about 4.6 GiB: every Treesitter grammar, all language
servers and debug adapters, Node.js, and the Claude CLI. Most of it comes from
`cache.nixos.org`. Custom derivations (NeoJJ, codedocs, the patched SCSS
grammar, the palette) are built locally unless a cache has them. The flake's
`nixConfig` asks to trust an extra substituter; answer the prompt or pass
`--accept-flake-config`.

## Version control

Repository actions use NeoJJ in the nearest jj repository and Neogit in a plain
Git repository. A colocated repository is treated as jj. The same actions are
available through `:Vcs [action]` and these mappings:

| Mapping | Action |
| --- | --- |
| `<leader>gg` | Status |
| `<leader>gc` | Commit |
| `<leader>gd` | Diff |
| `<leader>gf` | Fetch |
| `<leader>gl` | Log |
| `<leader>gp` | Push |
| `<leader>gr` | Rebase |
| `<leader>gm` | Remotes |
| `<leader>gb` | Git branches or jj bookmarks |
| `<leader>gw` | Git worktrees or jj workspaces |

Inside either status interface, the common popup keys are `c`, `d`, `f`, `l`,
`m`, `p`, and `r`. Git-only pull and merge remain available as `P` and `M` in
Neogit. Gitsigns operations are grouped under `<leader>gh`; for example,
`<leader>ghp` previews a hunk, `<leader>ghs` stages one, and `<leader>ghr`
reverts one.

diffs.nvim provides syntax-aware and intra-line highlighting in both status
interfaces. Its own `:Diff` command operates on Git objects, so the portable
diff entry point is `<leader>gd` or `:Vcs diff`.
