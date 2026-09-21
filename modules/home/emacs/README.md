# Emacs

A Nix-owned Emacs environment designed to sit alongside the Neovim module.
The development profile installs both. Neovim remains the default editor;
this module does not change `EDITOR`, `VISUAL`, Git/jj editor settings, or
enable an Emacs daemon. No configuration has to be downloaded at startup.

## Layout and ownership

| Path | Task |
| --- | --- |
| default.nix | Emacs packages, tools, grammars, generated settings |
| configs/early-init.el | Startup UI and package policy |
| configs/init.el | Explicit eager startup order |
| configs/lisp/options.el | Editing defaults and persistent undo |
| configs/lisp/keymap.el | Evil, Space leader, windows, editing primitives |
| configs/lisp/autocmds.el | Editing-buffer presentation and yank feedback |
| configs/lisp/config/ | Project roots, server table, shared theme |
| configs/lisp/languages/ | Modes, parser selection, filetype behavior |
| configs/lisp/plugins/ui/ | Pickers, sidebars, terminals, VCS, modeline |
| configs/lisp/plugins/smart/ | Completion, formatting, OpenCode ACP |
| configs/lisp/plugins/lsp/ | Server registration, diagnostics, navigation |
| configs/lisp/plugins/debug/ | Dape adapters and mappings |
| configs/lisp/plugins/integrations/ | Project compilation/tasks |
| tests/run-tests.el | Source and behavioral tests |


Startup follows the Neovim structure: globals, options, keymaps, buffer hooks,
languages, plugins, then theme. Nix generates `nix-settings.el` with fonts,
palettes, parser paths, executable paths, and debugger runtime locations.
Home Manager links the source files into `~/.config/emacs`. Edit this checkout,
not the generated store-backed configuration.

`../editor-tools/packages.nix` declares the external tools used by both editors.
`../editor-tools/default.nix` owns the shared Mago and rumdl fallback settings.
Project-local formatter settings take precedence. Emacs adds the TypeScript LSP
bridge, Git/jj UI executables, OpenCode, and process utilities to its own PATH.
The sibling AI module still owns OpenCode configuration, authentication choices,
agents, skills, and MCP servers.

Emacs activates the Nix-provided package autoloads locally; package archives
and automatic LSP downloads are disabled. Tree-sitter libraries are Nix-owned.
An installed grammar is used only when a compatible Emacs major mode exists.

## Familiar commands

`SPC` is the leader in Evil normal, visual, and motion states. Which-key displays
the same command groups after 300 ms. `M-x` remains available for native Emacs
commands; `C-g` cancels a prompt or command.

| Keys | Action |
| --- | --- |
| `C-h/j/k/l`, `SPC w` | Window navigation and Vim window commands |
| `SPC .`, `SPC f f`, `SPC SPC` | Files here, files here, project files |
| `SPC f r`, `SPC f p` | Recent files, editor configuration |
| `SPC ,`, `SPC b b` | Buffers |
| `SPC /`, `SPC *`, `SPC '` | Project grep, symbol grep, resume picker |
| `SPC s b`, `SPC s s`, `SPC s B` | Current buffer or open-buffer search |
| `SPC s t` | Command picker |
| `SPC h h`, `SPC h b b` | Help search, searchable bindings |
| `\`, `SPC o p`, `SPC s i` | File tree, file tree, symbol sidebar |
| `gd`, `gD`, `gr`, `gI`, `K` | Definition, declaration, references, implementation, hover |
| `SPC c a/r/t/S/j` | Code action, rename, type, file symbols, workspace symbols |
| `SPC c f` | Format buffer; LSP range formatting when a selection is active |
| `SPC c q/x/X` | Buffer diagnostics, project diagnostics, diagnostic picker |
| `SPC c c`, `SPC c C` | Run project task, show/hide compilation output |
| `SPC o t/T/f` | Toggle, new, focus terminal |
| `Esc Esc` in terminal | Return to normal state; `i` resumes terminal input |
| `SPC g g` | Blazingjj in jj repositories, Lazygit in Git repositories |
| `]c`, `[c`, `SPC g p` | Next/previous hunk, preview hunk |
| `SPC g s/r/S/R` | Stage/reset hunk, stage/reset file |
| `SPC g u` | Staged diff: select a hunk or lines, then `u` to unstage |
| `SPC g b/d/D` | Blame, unstaged diff, diff against HEAD |
| `SPC t v/l/h/b/D` | Whitespace, relative numbers, inlay hints, blame, deleted hunk preview |
| `SPC t T` | Additional manual light/dark appearance toggle |
| `F5/F10/F11/F12` | Start/continue, step over, step in, step out |
| `SPC d b/B/c/l/r/u/x/e` | Breakpoint, condition, continue, restart, REPL, debug UI, quit, evaluate |
| `SPC d L` | Attach to an external Neovim Lua debug server |
| `SPC o l l/a/m/M/r/R` | Chat, selection context, ACP mode/model, edit, fresh review |
| `SPC q q` | Quit, prompting to save modified buffers |

Ordinary Vim motions, operators, text objects, `gc` comments, persistent undo,
pairs, and `sa`/`sd`/`sr` surrounds are provided by Evil and its extensions.
Completion uses Corfu, Cape, LSP and Yasnippet, with documentation popups and
`C-h`/`C-l` snippet field navigation. Emacs 31 supports Corfu in terminals.

## Tooling parity

| Neovim subsystem | Emacs equivalent |
| --- | --- |
| Telescope / FZF / Which-key | Consult / Vertico / Orderless / Which-key |
| Neo-tree / Outline / Dropbar | Treemacs / Imenu List / Breadcrumb |
| Blink / LuaSnip | Corfu / Cape / Yasnippet, including LSP snippets |
| Native LSP / Trouble / Fidget | lsp-mode / Flymake / LSP progress and modeline |
| Conform | Apheleia formatter chains, LSP fallback |
| Treesitter / folds | Nix grammars, built-in TS modes, treesit-fold / Hideshow |
| Gitsigns / Heirline | Diff-hl / Magit / Blamer / custom cached modeline |
| Snacks terminal | Eat, with per-project reusable terminal buffers |
| Overseer | Compilation buffers and package.json task selection; arbitrary build commands |
| DAP / DAP UI / virtual text | Dape and its REPL, inspector, breakpoints and inlay hints |
| Avante OpenCode ACP | agent-shell OpenCode ACP using the same provider configuration |
| Render Markdown | Markdown markup concealment, native code highlighting, visual wrapping |
| TODO / color / indent highlights | hl-todo / rainbow-mode / highlight-indent-guides |
| Theme and system appearance | Shared Meowsoot/Kanagawa palettes, fonts, auto-dark |

Servers: Bash LS, zshcs (experimental diagnostics/hover), Zuban, Lua LS, nil,
Phpactor, rumdl, Some Sass, JSON LS, YAML LS, TypeScript LS, and additive Emmet.
Lua LS receives Neovim runtime and luvit annotations. Emmet expansion is also
available through `emmet-mode`. C/C++ have syntax support but no configured LSP,
matching Neovim. Project runtimes and build/test tools still belong in the
project environment.

The formatter chains are the same: CSS beautify; HTML Prettier; Lua StyLua;
Markdown mdsf then rumdl; PHP HTML beautify then Mago; Python Ruff fixes, format,
then import organization; Zsh Shellharden then shfmt. Explicit chains format
asynchronously on save. Other supported buffers use LSP formatting before save,
except C/C++. Markdown wraps visually while typing and reflows on formatting.

Repository detection chooses the nearest `.jj` or `.git`, preferring jj when
both exist. Project files and search work in non-colocated jj repositories too.
The modeline caches asynchronous repository-wide counts: Git counts unstaged
tracked changes; jj counts the working-copy commit `@`. Hunk actions remain Git
operations, including in colocated repositories.

## Deliberate differences and remaining gaps

This is a comparable workflow, not a claim of pixel-for-pixel or plugin-default
parity. These differences matter when switching:

- Visual partial-hunk actions open Magit's diff for selecting lines and applying
  `s`, `k`, or `u`. `g u` selects a staged hunk rather than maintaining a separate
  undo-last-stage stack. `t D` previews deleted hunk content, not an all-file
  virtual-deletion overlay.
- Range formatting requires LSP range support. Unsupported ranges report an
  error rather than silently formatting unrelated text. Save-time LSP fallback
  is synchronous; explicit Apheleia chains are asynchronous.
- Treemacs does not reproduce Neo-tree's pinned file-nesting rules. Buffers, Git
  status and document symbols are separate Consult/Magit/Imenu views instead of
  additional sources in one sidebar.
- Standard `scss-mode` handles SCSS editing. Neovim's custom SCSS parser patch
  and query set are not used by Emacs. Tridactyl files use generic configuration
  highlighting. Mini's extended text-object set and animation are not identical.
- Markdown rendering and color swatches use Emacs faces, not Neovim virtual
  text. Tailwind class-color previews are not reproduced. Modelines are per
  window rather than a single global statusline. Only the shared Nix theme
  families are supported, not the extra Lua-only Monokai selection.
- Task selection discovers package.json scripts; other build/task systems use
  the editable compilation command rather than Overseer's provider discovery.
- TypeScript uses the standard LSP bridge rather than typescript-tools.nvim.
  Emmet/web-mode offer tag editing, but automatic JSX closing-tag insertion is
  not a direct port of TypeScript Tools' behavior.
- Dape uses its own UI lifecycle. Node attach prompts for a PID. Zsh debugging
  is Bash-only, just as in Neovim. `d L` attaches to Neovim after starting its OSV
  server externally with `:lua require('osv').launch({port = 8086})`.
- AI edits use ACP tool permissions rather than Avante's inline diff-acceptance
  UI. No auto-approval or inline suggestions are enabled here. Existing OpenCode
  permissions remain authoritative. Explicit buffer context can include unsaved
  text; review the session's proposed operations before approving changes.

## Validation and trial

From the repository root, build without activating:

```bash
nix build --no-link --no-write-lock-file \
  '.#homeConfigurations."example-user@generic-linux".config.programs.emacs.finalPackage'

EMACS_NIX_SETTINGS=$(nix build --no-link --no-write-lock-file --print-out-paths \
  '.#homeConfigurations."example-user@generic-linux".config.xdg.configFile."emacs/nix-settings.el".source')
export EMACS_NIX_SETTINGS

nix shell '.#homeConfigurations."example-user@generic-linux".config.programs.emacs.finalPackage' \
  -c emacs --batch -q -l modules/home/emacs/tests/run-tests.el
```

The suite loads this checkout with generated settings, isolates Emacs state in
`/tmp/opencode`, and checks syntax, keymaps, project roots, all formatter chains,
live server initialization, real Git/jj counts, terminal input, surrounds and
the tree. It creates disposable repositories, not changes in this repository.
Some servers currently log `Unexpected params: null` during lsp-mode shutdown;
the initialization, completion and diagnostics checks still pass.

To try the same checkout interactively without activating Home Manager, keep
`EMACS_NIX_SETTINGS` exported and run:

```bash
nix shell '.#homeConfigurations."example-user@generic-linux".config.programs.emacs.finalPackage' \
  -c emacs -q \
  -l modules/home/emacs/configs/early-init.el \
  -l modules/home/emacs/configs/init.el
```

Add `-nw` for a terminal session. Normal activation installs the configuration
for plain `emacs`; activation is intentionally separate from these checks.
Existing `~/.emacs` or `~/.emacs.d/init.el` files can take precedence over the XDG
configuration and should be reviewed before activation, not automatically deleted.
