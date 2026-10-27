# Repository Guide for Agents

## Source of Truth

This repository is the editable source for a Nix flake. The currently installed
NixOS generation, Home Manager generation, programs, services, desktop files,
shell configuration, and application configuration normally come from an older
immutable `/nix/store` output. They do not reflect working-tree edits until the
relevant output has been built and activated.

Apply this rule repository-wide, not only to Neovim:

- Never use an installed component as the first validation of an unactivated
  working-tree change.
- Test source files directly when the component supports it.
- Otherwise evaluate or build the relevant flake output without activating it.
- Do not report a missing module, stale setting, or unchanged behavior from the
  installed generation as a source-code failure until the checkout or a newly
  built output has been tested.
- Do not run `nixos-rebuild switch`, `home-manager switch`, or another
  activating command unless the user explicitly requests activation.
- Do not edit files reached through `/run/current-system`, Home Manager profile
  links, generated files in the home directory, or paths in `/nix/store`. Change
  their source in this checkout.

This is a colocated Jujutsu/Git repository. Prefer `jj status`, `jj diff`, and
other idiomatic `jj` inspection commands. The working copy is commit `@`; there
is no staging area. Do not alter history, bookmarks, or the operation log unless
requested. Git-backed flake evaluation can omit files not present in the Git
source snapshot, so ensure newly added required files are visible to the flake
before trusting an evaluation.

## Safe Validation

Run commands from `/etc/nix-config`. Prefer evaluation and no-link builds:

```bash
nix flake show --no-write-lock-file .
nix flake check --no-build --no-write-lock-file .
nix build --no-link '.#nixosConfigurations.asgard.config.system.build.toplevel'
nix build --no-link '.#nixosConfigurations.example-nixos.config.system.build.toplevel'
nix build --no-link '.#homeConfigurations."example-user@generic-linux".activationPackage'
nix eval '.#homeConfigurations."example-user@macbook".activationPackage.drvPath'
nix eval '.#homeConfigurations."cbrst@niflheim".activationPackage.drvPath'
nix build --no-link '.#nvim' '.#nvim-lite'
nix eval '.#packages.aarch64-darwin.nvim.drvPath'
nix eval '.#packages.aarch64-darwin.nvim-lite.drvPath'
```

For Asgard's embedded Home Manager configuration:

```bash
nix build --no-link \
  '.#nixosConfigurations.asgard.config.home-manager.users.cbrst.home.activationPackage'
```

Use `--no-link` to avoid creating a root `result` symlink. Builds may populate
the Nix store but do not activate their outputs. Do not update `flake.lock` as
incidental validation. There is no flake `formatter`, `checks`, dev shell,
Makefile, or Justfile; do not claim that `nix fmt` is supported. The only CI
workflows build and update the documentation site (see "Documentation Site").

At minimum, also run the relevant source formatter or parser and:

```bash
jj diff --stat
git diff --check
```

Use tools from Nix explicitly when they are not in the current shell, for
example `nix shell nixpkgs#stylua -c stylua --check <files>`.

Activation commands, only when explicitly requested, are:

```bash
sudo nixos-rebuild switch --flake /etc/nix-config#asgard
nix run github:nix-community/home-manager -- switch \
  --flake '.#example-user@generic-linux'
```

Asgard embeds `cbrst`'s Home Manager configuration in the NixOS output, while
Niflheim exposes a standalone Home Manager output for the same user.

## Flake Architecture

`flake.nix` is the entry point. It pins `nixpkgs` unstable, Home Manager,
Affinity Nix, Noctalia, Noctalia Greeter, NUR, Serena, zshcs, and non-flake
package sources. Shared `defaultSettings` define fonts and the theme
family. Each host publishes its resolved `settings` through `_module.args`,
which lets the host apply machine-specific overrides before dependent modules
are evaluated.
`configLib` comes from `lib/default.nix`; flake inputs and shared defaults are
passed through `specialArgs` or `extraSpecialArgs`. `configLib.mkPkgs system`
imports nixpkgs with `allowUnfree`, NUR, and the local overlays; `mkHome` and the
flake `packages` both use it, so standalone outputs see the same package set.

Exported outputs:

| Output | Platform | Composition |
| --- | --- | --- |
| `nixosConfigurations.asgard` | `x86_64-linux` | Real Asgard host plus integrated Home Manager for `cbrst` |
| `nixosConfigurations.example-nixos` | `x86_64-linux` | Template NixOS host plus integrated Home Manager for `example-user` |
| `homeConfigurations."example-user@generic-linux"` | `x86_64-linux` | Standalone Home Manager development environment |
| `homeConfigurations."example-user@macbook"` | `aarch64-darwin` | Standalone Home Manager development environment plus macOS additions |
| `homeConfigurations."cbrst@niflheim"` | `aarch64-darwin` | Real Niflheim Home Manager environment for `cbrst` |
| `packages.<system>.nvim` | `x86_64-linux`, `aarch64-darwin` | Standalone Neovim from `modules/home/neovim/package.nix`, using `defaultSettings` and default features; `nix run .#nvim` |
| `packages.<system>.nvim-lite` | `x86_64-linux`, `aarch64-darwin` | Same, with the overrides in `modules/home/neovim/lite.nix` (no AI, debugging, PHP, Python, or web tooling; curated grammars) |

The normal composition flow is:

```text
flake output -> host -> profile -> module -> package/configuration output
```

Directory ownership:

| Path | Responsibility |
| --- | --- |
| `hosts/` | Machine-specific imports, hardware, boot, filesystems, and platform differences |
| `profiles/` | Role-oriented bundles of reusable modules |
| `modules/nixos/` | System services, hardware support, boot, and desktop facilities |
| `modules/home/` | User programs, dotfiles, and portable Home Manager features |
| `users/` | Person-specific Home Manager state and compatibility versions |
| `lib/` | Helper functions and theme data; these are not modules |
| `packages/` | Local derivations such as RTK and the Kanagawa GTK theme |
| `docs` branch | Fumadocs (Next.js) documentation site published to GitHub Pages; not on `main` |
| `overlays/` | Reserved/documented overlay location; currently no local overlay implementation |

Do not move host-specific values into reusable profiles or modules. Do not put
user preferences in hardware modules. Preserve `system.stateVersion` and
`home.stateVersion` unless intentionally performing a compatibility migration;
they are currently `26.05` and are not package-version pins.

## Composition Graphs

Asgard:

```text
flake.nix
└── hosts/nixos/asgard/
    ├── hardware-configuration.nix
    ├── modules/nixos/secure-boot.nix
    ├── modules/nixos/gaming.nix
    ├── profiles/nixos/desktop.nix
    │   └── modules/nixos/{base,archives,nautilus,fonts,gtk,multimedia,
    │                       niri,noctalia,noctalia-greeter,1password,pipewire}
    └── home-manager.users.cbrst
        ├── users/cbrst/home.nix
        ├── profiles/home/development.nix
        ├── profiles/home/gaming.nix
        └── profiles/home/desktop-linux.nix
            └── profiles/home/desktop-base.nix
```

Niflheim:

```text
flake.nix
└── hosts/home/niflheim.nix
    ├── users/cbrst/home.nix
    ├── profiles/home/development.nix
    └── profiles/home/desktop-base.nix
```

Home profiles:

```text
profiles/home/minimal.nix
└── modules/home/{shell,ssh,vcs,bitwarden}

profiles/home/development.nix
├── profiles/home/minimal.nix
└── modules/home/{code,neovim,ai,direnv}

profiles/home/gaming.nix
└── modules/home/mangohud.nix

profiles/home/desktop-base.nix
└── modules/home/{fonts,ghostty}

profiles/home/desktop-linux.nix
├── profiles/home/desktop-base.nix
└── modules/home/{affinity,firefox,imv,mpv,nautilus,niri,noctalia}
```

`example-nixos` is a template with placeholder disk/boot values and must not be
applied unchanged. `hosts/nixos/asgard/hardware-configuration.nix` contains real
machine UUIDs. Secure Boot installation has a deliberate two-stage process
documented in `INSTALL.md`; do not casually change or execute it. Never add
credentials, password hashes, SSH private keys, Secure Boot keys, or vault
exports to the flake.

## Generated and External State

Home Manager source assets live under each module, often in `configs/`.
`xdg.configFile`, `home.file`, `environment.etc`, `writeShellApplication`, and
template helpers turn them into store outputs and profile links. In particular,
`configLib.renderTemplate` in `lib/default.nix` substitutes theme/font values in
checked-in source files.

`lib/themes.nix` is the single source of colours. Each family has semantic
`light`/`dark` palettes plus a `terminal` set (16 ANSI colours, cursor and
selection) derived with the `configLib.colors` helpers from `lib/colors.nix`.
Neovim, Ghostty, foot, Firefox, Noctalia and the shell prompt all render from
it, so a new family only needs palette entries there.

External mutable state intentionally outside the repository includes account
passwords, `/var/lib/sbctl`, `~/.ssh/hosts`, and password-manager agent sockets.
Do not attempt to make these declarative unless the user specifically requests a
secrets-management design.

The Karabiner-Elements application is also installed externally with its
official macOS installer. `modules/home/karabiner/` owns only
`~/.config/karabiner/karabiner.json`; do not add `pkgs.karabiner-elements` to
Home Manager because it does not install the required root-owned services or
DriverKit system extension.

Raycast is likewise installed outside Nix (official installer or
`brew install --cask raycast`). Do not add `pkgs.raycast` to Home Manager:
every activation replaces the app bundle, and its databases and extensions
(`~/Library/Application Support/com.raycast.macos`, `~/.config/raycast`) were
being lost or broken. Raycast updates itself from `/Applications`.

## Neovim Ownership

The Home Manager module is `modules/home/neovim/default.nix`. It is imported by
`profiles/home/development.nix`, so Asgard and all standalone development
outputs receive the same editor setup.

The editor itself is defined once in `modules/home/neovim/spec.nix`. It is a
plain function, not a module:

```text
spec.nix { pkgs, lib, inputs, settings, features, claudeCode }
  -> { package, extraPackages, plugins, configDir }
```

`features` is the resolved `editor.neovim.features` option set declared in
`modules/home/neovim/options.nix`. Every switch defaults to on:

| Option | Removes when disabled |
| --- | --- |
| `ai.enable` | claudecode.nvim and the Claude CLI |
| `debug.enable` | nvim-dap, dap-ui, virtual text, nvim-nio, osv, and the `debug` tool group |
| `grammars` (`"all"` or a list of names) | Every Treesitter grammar not listed |
| `languages.<name>.enable` | That `tools.nix` language group; `web` also removes nvim-vtsls and nvim-ts-autotag |

Hosts set them like any Home Manager option, for example
`editor.neovim.features.languages.php.enable = false;` in
`hosts/home/niflheim.nix`. `package.nix` evaluates the same `options.nix` with
`lib.evalModules`, so the standalone packages share defaults and type checks.
Unknown names and wrong types fail evaluation; `spec.nix` also rejects grammar
names missing from `builtGrammars` and language lists that differ between
`options.nix` and `tools.nix`.

The Lua configuration learns the result from a generated
`init6.generated.features` module (built like `init6.generated.palette`), read
through `init6.config.features`. That module falls back to "everything enabled"
when the generated module is absent, as it is in an older installed generation.
Lua that sets up a feature-specific plugin or tool must check it first:

- `features.ai`: claudecode setup, the Heirline Claude segment, the dashboard
  key, and the Snacks `<a-o>` picker action.
- `features.debug`: `plugins.debug`.
- `features.language(name)`: LSP servers (through `server_languages` in
  `plugins/lsp/init.lua`), Conform formatters (through `filetype_languages` in
  `plugins/smart/autoformat.lua`). Servers and
  formatters of a disabled language are skipped without the "missing tools"
  warning. Add new servers and formatted filetypes to those maps.

Two consumers wrap it:

| Consumer | Wrapper | Config location | `claudeCode` |
| --- | --- | --- | --- |
| `default.nix` (Home Manager) | `programs.neovim` | Linked into `~/.config/nvim` | `programs.claude-code.finalPackage` |
| `package.nix` (`packages.<system>.nvim`) | `pkgs.wrapNeovimUnstable` | Bundled in the store, loaded through the wrapper's `-u` init | `pkgs.claude-code` |

`package.nix` mirrors Home Manager's wrapping (`extraPackages` appended with
`--suffix PATH`, Python and Ruby providers off). It also sets `NVIM_APPNAME` to
`init6` as a default, so shada, undo, swap and state stay separate from any
other Neovim on the machine. It sets `vim.g.init6_config_dir` to the bundled
configuration (the Telescope "find file in Neovim config" mapping uses it), and
it creates `stdpath("data")` on start because a fresh machine lacks it. Rules:

- Declare plugins, grammars, custom plugin derivations, and helper scripts in
  `spec.nix`, not in `default.nix` or `package.nix`. A change there must keep
  both consumers working.
- Lua must not assume `~/.config/nvim`. Use
  `vim.g.init6_config_dir or vim.fn.stdpath("config")` when the configuration
  directory itself is needed.
- Home Manager-only files (`xdg.configFile`, such as the Mago and rumdl
  fallbacks in `default.nix`) are absent from the standalone package.
- Do not read Home Manager `config` inside `spec.nix`. Pass such values in as
  arguments, as `default.nix` does with `programs.claude-code.finalPackage`.
- `spec.nix` returns `configDir` as a Nix path. `default.nix` joins it with `+`
  so each linked file keeps its own store path; interpolating there would copy
  the whole directory and change the Home Manager outputs. `package.nix`
  interpolates on purpose, because it needs the directory as one store path.

Nix owns the Neovim runtime surface:

- `spec.package` is `neovim-unwrapped`; each consumer creates the final wrapped
  package.
- `spec.plugins` declares every plugin and Treesitter grammar. There is no
  Lazy.nvim, packer, Mason, or runtime plugin/parser installation.
- `spec.extraPackages` supplies LSP servers, formatters, debug adapters, search
  tools, and other executables on Neovim's `PATH`. Most of them come from
  `modules/home/neovim/tools.nix`, which returns named groups: `core`,
  `runtimes`, `debug`, and `languages.<family>` (`lua`, `markdown`, `nix`,
  `php`, `python`, `shell`, `web`, `yaml`). `spec.nix` always includes `core`
  and `runtimes`, and the others as their features allow. A package may appear
  in several language groups; `spec.nix` deduplicates. No two distinct packages
  ship the same command, so group order does not change which executable a
  command resolves to. Keep that property
  when adding packages, and add a new language family to both `tools.nix` and
  `options.nix`.
- Under Home Manager, `xdg.configFile."nvim/init.lua"`,
  `xdg.configFile."nvim/lua"`, and `xdg.configFile."nvim/colors"` install the
  source under `modules/home/neovim/configs/` into `~/.config/nvim` through
  immutable store-backed links. `default.nix` also writes the Mago and rumdl
  fallback configurations (project-local configuration wins).
- The generated `init6-palette` plugin exposes the shared theme palette from
  `lib/themes.nix` as the `init6.generated.palette` Lua module. The `init6`
  colorscheme (`configs/colors/init6.lua`, implemented in
  `plugins/theme/colorscheme/`) builds every highlight group from it; there are
  no third-party colorscheme plugins. New plugins with their own highlight
  groups get entries in `plugins/theme/colorscheme/groups/`.
- Python and Ruby providers are intentionally disabled.

When adding a plugin or parser, update `spec.nix`; for an LSP server, formatter,
debug adapter, or command, add it to the matching group in `tools.nix` (a new
language family gets its own list under `languages`). Do not assume a
host-global executable or runtime download. Adding a Lua `require` without
declaring its plugin in Nix can make startup fail. NeoJJ is a pinned local Vim
plugin derivation because it is not available in the pinned nixpkgs. `blazingjj`
and `lazygit` remain supplied by `modules/home/vcs/default.nix` for shell use,
not for the Neovim VCS UI.

## Neovim Startup Order

The entry point is `modules/home/neovim/configs/init.lua`. Startup is eager and
ordered:

```text
init6.config.globals.setup()
init6.options
init6.keymap
init6.autocmds
init6.languages.setup()
init6.plugins.setup()
init6.config.theme.set_colorscheme()
```

The theme is applied last because colorschemes clear generated Heirline and UI
highlight groups.

`configs/lua/init6/plugins/init.lua` then loads:

```text
todo-comments
init6.plugins.theme
init6.plugins.ui
init6.plugins.ui.mini
init6.plugins.ui.neo-tree
init6.plugins.ui.vcs
init6.plugins.ui.heirline
init6.plugins.ui.telescope
init6.plugins.ui.remote
init6.plugins.ui.which-key
init6.plugins.ui.snacks
init6.plugins.ui.outline
init6.plugins.ui.nvim-highlight-colors
init6.plugins.ui.gitsigns
init6.plugins.debug
init6.plugins.smart
init6.plugins.lsp
init6.plugins.integrations
```

Preserve meaningful ordering:

- Leaders are set before mappings.
- Mini Icons provides `nvim-web-devicons` compatibility before consumers load.
- VCS state and the Neogit/NeoJJ interfaces initialize before Heirline consumes
  them. The diffs.nvim global configuration is also set before Vim sources its
  plugin runtime.
- Blink and LazyDev initialize before LSP capabilities and Lua completion use
  them.
- Auto Dark Mode is configured before the final colorscheme application.

## Neovim Lua Map

| Path | Responsibility |
| --- | --- |
| `configs/lua/init6/health.lua` | `:checkhealth init6`: generated modules, enabled features, and the tools they need |
| `configs/lua/init6/options.lua` | Editor options, clipboard scheduling, folds, indentation defaults |
| `configs/lua/init6/keymap.lua` | Global mappings and navigation |
| `configs/lua/init6/autocmds.lua` | Yank highlighting and editing-buffer status column |
| `configs/lua/init6/languages/` | Filetype-specific behavior; register new modules in `languages/init.lua` |
| `configs/lua/init6/config/globals.lua` | Leaders and global capability flags |
| `configs/lua/init6/config/features.lua` | Nix-selected features from the generated `init6.generated.features` module |
| `configs/lua/init6/config/lsp_servers.lua` | Declarative LSP server table |
| `configs/lua/init6/config/lsp_keymaps.lua` | `LspAttach` mappings, highlights, and inlay hints |
| `configs/lua/init6/config/theme.lua` | Light/dark variant selection and colorscheme application |
| `configs/lua/init6/config/ui_colors.lua` | Shared StatusLine, WinBar, Dropbar, and message colors |
| `configs/lua/init6/config/util.lua` | Generic command/visual-selection helpers |
| `configs/lua/init6/utils/icons.lua` | Shared icons |
| `configs/lua/init6/plugins/theme/` | The `init6` colorscheme (palette roles, highlight groups) and Auto Dark Mode setup |
| `configs/lua/init6/plugins/ui/` | Statusline, navigation, pickers, VCS, terminals, symbols, and visual UI |
| `configs/lua/init6/plugins/smart/` | Completion, Treesitter, formatting, and AI integrations |
| `configs/lua/init6/plugins/debug/` | DAP adapters, debugger UI, and debug keymaps |
| `configs/lua/init6/plugins/lsp/` | LSP capability merge, executable checks, and server enablement |
| `configs/lua/init6/plugins/integrations/` | Overseer and cross-plugin workflows |

All custom Lua lives in the `init6` namespace (`configs/lua/init6/`, required as
`init6.*`); only `init.lua` and `colors/init6.lua` sit outside it. Do not add
top-level Lua modules: generic names like `config` or `utils` collide with
plugin modules on the runtimepath. Nix-generated modules use
`init6.generated.*`, and autocommand groups are named `init6-<purpose>`. Short
paths in the rest of this guide, such as `plugins/ui/vcs.lua`, are relative to
`configs/lua/init6/`.

Plugin aggregators expose `M.setup()` and use explicit ordered `require` calls.
Keep plugin-specific state and orchestration under `plugins/<group>/`; use
`config/` for shared editor policy/state, `utils/` for genuinely generic
helpers, and `languages/` for filetype behavior.

## Neovim Subsystems

LSP uses the newer `vim.lsp.config`/`vim.lsp.enable` API. Blink capabilities are
merged into configured servers. Servers of a disabled language group are
skipped; the rest are enabled only when their resolved command is executable.
TypeScript and JavaScript use vtsls, a regular server in the `web` group. Server
definitions belong in `config/lsp_servers.lua`, mappings in
`config/lsp_keymaps.lua`, server-to-language mapping and orchestration in
`plugins/lsp/init.lua`, and package declarations in `tools.nix`.
`plugins/lsp/vtsls.lua` sets up nvim-vtsls (`:VtsExec`) and its buffer-local
mappings (`<leader>co`, `cm`, `cu`, `cF`, `cR`, `gS`, and the `<leader>cT`
group). nvim-vtsls has no licence file, so nixpkgs marks it unfree;
`configLib.mkPkgs` allows that.

claudecode.nvim is the active Neovim AI integration. It starts the Claude Code
CLI through a right-side Snacks terminal, exposes editor context through its IDE
bridge, and is included on Neovim's wrapped `PATH`; Claude Code's Home Manager
configuration remains owned by `modules/home/ai/`. Avante remains declared and
configured as an inactive alternative, but its setup is disabled in
`plugins/smart/init.lua`.

Debugging uses nvim-dap with Nix-owned adapters for Python, JavaScript and
TypeScript, Bash-compatible shell scripts, standalone Lua, and Neovim Lua. The
Bash adapter is also offered for `zsh` buffers, but it cannot interpret
Zsh-specific syntax because no native Zsh DAP adapter is available.

Completion is configured in `plugins/smart/autocompletion.lua`. Sources are
LazyDev, LSP, paths, LuaSnip, and buffer completion. Formatting is configured in
`plugins/smart/autoformat.lua` through Conform and runs on save. Current chains
include StyLua for Lua, mdsf then rumdl for Markdown, Ruff operations for
Python, Shellharden then shfmt for Zsh, `oxlint-unused-imports` then oxlint then
oxfmt for JavaScript and TypeScript, oxlint then oxfmt for Vue, oxfmt for the
other web filetypes, JSON, and TOML, and yamlfmt for YAML.
`oxlint-unused-imports` is a `tools.nix` script that deletes unused imports
through oxlint's `no-unused-vars` suggestion fix; it stays off Vue and Svelte,
whose template usage oxlint cannot see. oxfmt uses the project's own
configuration, or else the bundled `configs/oxfmtrc.json` (passed with `-c`;
Home Manager links it to `~/.config/nvim/oxfmtrc.json`), which enables
`sortImports` and `sortTailwindcss`. nvim-ts-autotag, set up in
`plugins/smart/treesitter.lua` with the `web` group, closes and renames paired
tags.

UI responsibilities:

- `plugins/ui/heirline.lua`: global statusline presentation only.
- `plugins/ui/vcs.lua`: asynchronous Git/jj root detection, cached repository
  diff counters, identity metadata, refresh events, and repository-aware
  Neogit/NeoJJ dispatch. `.jj` wins in colocated repositories. Shared `:Vcs`
  actions and `<leader>g` mappings use NeoJJ for jj and Neogit for plain Git.
  Git counters are unstaged tracked changes; jj counters cover working-copy
  commit `@`.
- `plugins/ui/snacks.lua`: Snacks input, picker, and terminal mappings.
- `plugins/ui/dashboard.lua`: Snacks start screen options (keys, cwd recent
  files, fortunes, centred Pokémon pane via `scripts/dashboard-pokemon`),
  passed in by `snacks.lua`.
- `plugins/ui/gitsigns.lua`: current-buffer Git hunks and `<leader>gh` hunk
  actions.
- diffs.nvim: syntax-aware and intra-line highlighting for Neogit, NeoJJ,
  Gitsigns previews, Telescope previews, commit diffs, and conflict markers.
  Its standalone `:Diff` command remains Git-specific and is not the shared VCS
  dispatcher.
- `plugins/ui/telescope.lua`: Ivy-style file/search/buffer/LSP workflows. Its
  project-root helper uses the nearest `.jj` or `.git` marker.
- `plugins/ui/remote.lua`: remote-sshfs.nvim, which mounts SSH hosts under
  `~/.sshfs/<host>` (`<leader>R` mappings, host list from `~/.ssh/config` and
  `~/.ssh/hosts`). `contains(path)` marks mount paths by string comparison;
  format on save, the VCS statusline, Gitsigns, and Neo-tree git status
  (while the working directory is on a mount) are off there. `sshfs` is in the
  `core` tool group; macOS additionally needs macFUSE installed outside Nix.
  `<leader>Rs` opens a right-side Snacks terminal on the connected host (or a
  picked one) with mosh, falling back to ssh when mosh is absent locally or
  fails to start; `mosh` is also in `core`.
- `plugins/ui/neo-tree.lua`: filesystem, buffers, Git, symbols, nesting, and
  current-file following.
- `plugins/ui/mini.lua`: text objects, surrounds, pairs, indent scope, icons,
  and animation.
- `plugins/ui/block-brackets.lua`: a decoration provider that draws bracket
  pairs spanning several lines, and a semicolon right after the closer, with
  `Init6BlockBracket` (the indent-guide shade), from the trees of the
  active Treesitter highlighter. On unless `vim.g.init6_dim_block_brackets` is
  `false`; `<leader>tB` toggles it.

Treesitter grammars come from Nix. Do not reintroduce dynamic parser downloads
without redesigning ownership. Nerd Font support is assumed; the portable
desktop profile installs the configured fonts through Home Manager.

## Neovim Validation Before Activation

For Lua-only changes, prepend the checkout to `runtimepath` and explicitly use
the checkout's `init.lua`. Do this on the first attempt; a plain installed
`nvim --headless` tests the previous Home Manager generation.

```bash
nvim -n --headless \
  --cmd "set runtimepath^=$PWD/modules/home/neovim/configs" \
  -u "$PWD/modules/home/neovim/configs/init.lua" \
  '+qa'
```

This uses the installed generation's plugins, including its generated palette
module. When that generation predates `init6.generated.palette` (anything built
before the init6 namespace), the `init6` colorscheme warns and falls back to
`default`. Theme or palette changes therefore need the standalone package or the
generation pack directory below. `:checkhealth init6` reports which generated
modules and tools the running editor has.

If plugin or executable declarations changed, or the change touches theme
values, run the standalone package. It is built entirely from the checkout
(plugins, tools, palette, and Lua), so it needs no installed generation. Point
the XDG directories at a scratch location so the run leaves no state behind:

```bash
scratch="$(mktemp -d)"
env XDG_CONFIG_HOME="$scratch/config" XDG_DATA_HOME="$scratch/data" \
  XDG_STATE_HOME="$scratch/state" XDG_CACHE_HOME="$scratch/cache" \
  nix run '.#nvim' -- -n --headless path/to/real/file '+qa'
```

Run the same command with `'.#nvim-lite'` whenever a change touches
feature-specific Lua or `spec.nix`: it is the build with AI, debugging, and the
PHP, Python, and web groups disabled, so it exercises the feature checks. Open
files of disabled languages too; startup and editing must stay free of errors
and "missing tools" warnings.

To test the Home Manager wrapper itself rather than the standalone one, build
the Home Manager generation so its generated pack directory and wrapped package
are both available. Add that pack directory before loading the checkout
configuration:

```bash
generation="$(nix build --no-link --print-out-paths \
  '.#homeConfigurations."example-user@generic-linux".activationPackage')"

nix shell \
  '.#homeConfigurations."example-user@generic-linux".config.programs.neovim.finalPackage' \
  -c nvim -n --headless \
  --cmd "set packpath^=$generation/home-files/.local/share/nvim/site" \
  --cmd "set runtimepath^=$PWD/modules/home/neovim/configs" \
  -u "$PWD/modules/home/neovim/configs/init.lua" \
  '+qa'
```

Format only changed Lua files, preferably with the declared formatter:

```bash
nix shell nixpkgs#stylua -c stylua --check path/to/changed.lua
```

When validating asynchronous UI integrations, open a real file inside a test
repository, add the checkout runtime path, wait for the callback, and inspect
the returned state. An unnamed buffer may resolve roots differently and is not a
sufficient VCS test.

## Documentation Site

The documentation site lives on the separate `docs` branch, not on `main`. It
is a Fumadocs project on Next.js at that branch's root, statically exported
and published to <https://cbrst.github.io/nix/>. Pages are MDX in
`content/docs/`, ordered by a `meta.json` per folder, and describe the current
configuration; they are not a changelog. Internal links omit the `/nix` base
path, which Next.js adds.

`.github/workflows/docs-sync.yml` on `main` runs Claude Code on pushes to
`main` that change configuration. It checks out the `docs` branch into
`docs/`, revises the affected pages for the commits since the branch's
`.last-sync`, opens or updates a `docs-sync` pull request against `docs`,
merges it once the site builds, and then calls the `docs` branch's
`.github/workflows/docs-deploy.yml` to publish. That deploy workflow also runs
on direct pushes to `docs`. The sync agent follows
`.github/docs-sync-prompt.md`. Because the bot never merges into `main`, it
does not move `main@origin` underneath local work.

When a change alters behaviour that the pages describe, the sync workflow
updates the pages after the change reaches `main`. To edit pages by hand, use
a separate workspace outside this checkout (`/docs/` is ignored on `main`):

```bash
jj workspace add ../nix-docs -r docs
cd ../nix-docs
nix shell nixpkgs#nodejs -c npm ci
nix shell nixpkgs#nodejs -c npm run build
```

Fetch before editing, since the bot advances `docs@origin`.

## Change Discipline

### General Rules

- Make the smallest correct change and preserve explicit module boundaries.
- Do not rewrite generated hardware configuration or template hosts while
  working on unrelated features.
- Do not activate, reboot, enroll keys, partition disks, update lock files, or
  change bookmarks/history as validation.
- Preserve unrelated working-copy changes; this repository may be edited by
  multiple agents or the user concurrently.
- Update this guide when structure, output names, validation commands, or Neovim
  load order materially changes.
