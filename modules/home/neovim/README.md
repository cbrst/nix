# Neovim Module

This directory keeps the Neovim installation and its personal configuration
together.

## Layout

| Path | Role |
| --- | --- |
| `spec.nix` | The editor definition: unwrapped Neovim, plugins and Treesitter grammars, the tools on `PATH`, and the Lua configuration directory, all selected by features |
| `options.nix` | The `editor.neovim.features` options and their defaults |
| `tools.nix` | External executables on the editor's `PATH`, in named groups (see below) |
| `default.nix` | Home Manager module: imports `options.nix`, feeds `spec.nix` into `programs.neovim`, links the configuration into `~/.config/nvim`, and writes the Mago/rumdl fallback configuration |
| `package.nix` | Standalone wrapper published as `packages.<system>.nvim` and `nvim-lite` |
| `lite.nix` | Feature overrides for `nvim-lite` |
| `configs/` | `init.lua`, `colors/init6.lua`, and the `init6` Lua namespace under `lua/init6/`; plain Lua, testable straight from the checkout |
| `scripts/` | Helper scripts packaged by `spec.nix`, such as the dashboard Pokémon |
| `patches/` | Source patches for packaged dependencies (the SCSS grammar) |

The development profile imports this module, so every host using that profile
receives the editor; the features below decide how much of it.

## The editor definition

`spec.nix` is a plain function rather than a Home Manager module:

```nix
import ./spec.nix {
  inherit pkgs lib inputs settings features;
  claudeCode = <package>;
}
# => { package; extraPackages; plugins; configDir; }
```

Because it does not depend on Home Manager, two wrappers share it: `default.nix`
for Home Manager and `package.nix` for the standalone packages. Home
Manager-only values are passed in as arguments. `claudeCode` is
`programs.claude-code.finalPackage` under Home Manager and `pkgs.claude-code` in
the standalone packages.

To add something:

- a plugin or grammar: add it to `plugins` in `spec.nix` (to the matching
  `lib.optionals` block if it belongs to a feature), then `require` it from the
  Lua configuration behind the same feature check;
- a custom or pinned plugin: add a `buildVimPlugin` derivation in the `let`
  block of `spec.nix`, then list it in `plugins`;
- an LSP server, formatter, or debug adapter: add it to the matching group in
  `tools.nix`; for a server or formatted filetype, also map it to its language
  in `lua/init6/plugins/lsp/init.lua` (`server_languages`) or
  `lua/init6/plugins/smart/autoformat.lua` (`filetype_languages`);
- a language family: add a list under `languages` in `tools.nix` and an entry in
  `languages` in `options.nix`; evaluation fails if the two differ;
- a Home Manager-only value: add an argument to `spec.nix` and pass it from both
  `default.nix` and `package.nix`.

## The init6 namespace

The configuration is branded *init6*, which is also what the dashboard logo
spells. All custom Lua lives in that namespace, so nothing collides with plugin
modules that use generic names such as `config` or `utils`:

| Name | What it is |
| --- | --- |
| `lua/init6/…`, required as `init6.*` | Every hand-written module: `options`, `keymap`, `autocmds`, `config`, `languages`, `plugins`, `utils` |
| `init6.generated.palette`, `init6.generated.features` | Lua modules that `spec.nix` generates from Nix, shipped as separate plugins |
| `:colorscheme init6` | The theme built from `lib/themes.nix`, implemented in `init6.plugins.theme.colorscheme` |
| `init6-<purpose>` | Every autocommand group the configuration creates |
| `vim.g.init6_config_dir` | The bundled configuration path in the standalone packages |
| `:checkhealth init6` | Generated modules, enabled features, and whether the tools they need are on `PATH` |

Only `init.lua` (the entry point) and `colors/init6.lua` sit outside
`lua/init6/`, because Neovim looks for them by fixed paths. New modules go under
`lua/init6/` too.

## Features

`options.nix` declares `editor.neovim.features`. Everything is on by default, so
a host that sets nothing gets the full editor:

| Option | Default | When disabled |
| --- | --- | --- |
| `ai.enable` | `true` | No claudecode.nvim or Claude CLI; no Claude statusline segment, dashboard key, or `<a-o>` picker action |
| `debug.enable` | `true` | No nvim-dap, dap-ui, virtual text, nvim-nio, osv, or debug adapters; `plugins/debug/` is not loaded |
| `grammars` | `"all"` | A list of `builtGrammars` names installs only those parsers |
| `languages.<name>.enable` | `true` | No tools from that group, and no LSP or Conform setup for it; `web` also drops typescript-tools.nvim |

Languages: `lua`, `markdown`, `nix`, `php`, `python`, `shell`, `web`, `yaml`.
`tools.nix` lists the packages in each.

A host sets them next to its other configuration:

```nix
# hosts/home/niflheim.nix
editor.neovim.features = {
  debug.enable = false;
  languages.php.enable = false;
};
```

Mistakes fail evaluation instead of producing a half-working editor: unknown
options, wrong types, unknown grammar names, and language lists that differ
between `options.nix` and `tools.nix`.

### How the Lua side follows

`spec.nix` generates an `init6.generated.features` Lua module from the resolved
values, packaged like `init6.generated.palette`. `init6.config.features` reads
it and exposes `features.ai`, `features.debug`, and `features.language(name)`;
every setup that needs a feature-specific plugin or executable checks it first.
Without the generated module (for example, when the checkout is tested against
an older installed generation), everything counts as enabled.

Servers and formatters of a disabled language are skipped quietly. Only an
*enabled* language whose server is missing from `PATH` produces the "Missing
Home Manager LSP tools" warning, which then points at a real packaging problem
and refers to `:checkhealth init6`.

Grammars need no Lua changes: Treesitter start-up already tolerates a missing
parser, and those filetypes fall back to regex syntax highlighting.

## Tool groups

`tools.nix` returns an attribute set of package lists instead of one flat list:

| Group | Contents | Included |
| --- | --- | --- |
| `core` | `file`, `man-db`, `ripgrep`, `tree-sitter` | Always |
| `runtimes` | `bash`, `lua`, `nodejs`, `python3`, `zsh` | Always |
| `debug` | bashdb and its adapter, the local Lua adapter, debugpy, vscode-js-debug | `debug.enable` |
| `languages.lua` | lua-language-server, StyLua | `languages.lua.enable` |
| `languages.markdown` | mdsf, rumdl | `languages.markdown.enable` |
| `languages.nix` | nil, nixd | `languages.nix.enable` |
| `languages.php` | js-beautify (`html-beautify`), Mago, Phpactor | `languages.php.enable` |
| `languages.python` | Ruff, Zuban | `languages.python.enable` |
| `languages.shell` | bash-language-server, Shellharden, shfmt, zshcs | `languages.shell.enable` |
| `languages.web` | Emmet, js-beautify (`css-beautify`), Prettier, Some Sass, TypeScript (`tsserver`), vscode-langservers-extracted | `languages.web.enable` |
| `languages.yaml` | yaml-language-server | `languages.yaml.enable` |

Interpreters live in `runtimes` rather than `debug` because debug launches,
Overseer tasks, terminals, and language tooling all use them. A package may sit
in several language groups when several families need it (js-beautify);
`spec.nix` removes duplicates. No two distinct packages ship a command with the
same name, so the order of groups on `PATH` never changes which executable runs;
keep it that way when adding packages.

## Standalone editor

The flake publishes the editor as two packages for `x86_64-linux` and
`aarch64-darwin`. Both run on any machine with Nix (flakes enabled), without
Home Manager or this repository's activation:

| Package | Features | Closure |
| --- | --- | --- |
| `nvim` | Defaults: everything | About 4.6 GiB |
| `nvim-lite` | `lite.nix`: no AI or debugging; Lua, Markdown, Nix, shell and YAML tooling; 24 grammars for configuration, scripting and VCS files | About 2.1 GiB |

```bash
nix run .#nvim -- file.txt                      # from a checkout
nix run github:cbrst/nix#nvim-lite -- file.txt  # from anywhere
nix profile install github:cbrst/nix#nvim       # keep it installed
```

`package.nix` accepts a `features` argument in the same shape as the Home
Manager option and evaluates it against `options.nix`, so a new variant is one
attribute set and one line in `flake.nix`.

How the standalone packages differ from the Home Manager editor:

- **Configuration** is bundled in the store and loaded through the wrapper's
  `-u` init file. `~/.config/nvim` is never read, so a machine's own Neovim
  configuration is unaffected. `vim.g.init6_config_dir` holds the bundled path;
  `<leader>fp` searches it.
- **State** lives under `NVIM_APPNAME=init6`, e.g. `~/.local/state/init6` and
  `~/.local/share/init6`, separate from any other Neovim; `nvim` and `nvim-lite`
  share it. The wrapper only sets a default, so
  `NVIM_APPNAME=other nix run .#nvim` overrides it.
- **Theme and fonts** come from the flake's `defaultSettings`, not a host's
  overrides. The terminal must still provide a Nerd Font.
- **Claude Code** (full `nvim` only) is plain `pkgs.claude-code`, without the
  plugins, skills and settings that `modules/home/ai/` configures.
  claudecode.nvim works, but the CLI uses whatever `~/.claude` the machine has.
- **Mago and rumdl fallbacks** are not written, because they are Home Manager
  files. Project-local configuration still applies.

Most of the closure comes from `cache.nixos.org`. Custom derivations (NeoJJ,
codedocs, the patched SCSS grammar, the palette and feature modules) are built
locally unless a cache has them. The flake's `nixConfig` asks to trust an extra
substituter; answer the prompt or pass `--accept-flake-config`.

In `nvim-lite`, about 1.3 GiB of the 2.1 GiB is `zshcs` (shell group), whose
output keeps a reference to the Rust toolchain it was built with. Fixing that
reference in the zshcs package would shrink both variants.

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
