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
```

For Asgard's embedded Home Manager configuration:

```bash
nix build --no-link \
  '.#nixosConfigurations.asgard.config.home-manager.users.cbrst.home.activationPackage'
```

Use `--no-link` to avoid creating a root `result` symlink. Builds may populate
the Nix store but do not activate their outputs. Do not update `flake.lock` as
incidental validation. There is no flake `formatter`, `checks`, dev shell, CI
workflow, Makefile, or Justfile; do not claim that `nix fmt` is supported.

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

There is no standalone `cbrst` Home Manager flake output; Asgard embeds that
user's Home Manager configuration in the NixOS output.

## Flake Architecture

`flake.nix` is the entry point. It pins `nixpkgs` unstable, Home Manager,
Noctalia, Noctalia Greeter, NUR, Serena, zshcs, and non-flake theme/package
sources. Shared `defaultSettings` define fonts and the theme family. Each host
publishes its resolved `settings` through `_module.args`, which lets the host
apply machine-specific overrides before dependent modules are evaluated.
`configLib` comes from `lib/default.nix`; flake inputs and shared defaults are
passed through `specialArgs` or `extraSpecialArgs`.

Exported outputs:

| Output | Platform | Composition |
| --- | --- | --- |
| `nixosConfigurations.asgard` | `x86_64-linux` | Real Asgard host plus integrated Home Manager for `cbrst` |
| `nixosConfigurations.example-nixos` | `x86_64-linux` | Template NixOS host plus integrated Home Manager for `example-user` |
| `homeConfigurations."example-user@generic-linux"` | `x86_64-linux` | Standalone Home Manager development environment |
| `homeConfigurations."example-user@macbook"` | `aarch64-darwin` | Standalone Home Manager development environment plus macOS additions |

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
    ├── profiles/nixos/desktop.nix
    │   └── modules/nixos/{base,archives,nautilus,fonts,gtk,multimedia,
    │                       niri,noctalia,noctalia-greeter,1password,pipewire}
    └── home-manager.users.cbrst
        ├── users/cbrst/home.nix
        ├── profiles/home/development.nix
        └── profiles/home/desktop-linux.nix
            └── profiles/home/desktop-base.nix
```

Home profiles:

```text
profiles/home/minimal.nix
└── modules/home/{shell,ssh,git,bitwarden}

profiles/home/development.nix
├── profiles/home/minimal.nix
└── modules/home/{jj,code,neovim,ai,direnv}

profiles/home/desktop-base.nix
└── modules/home/{fonts,ghostty}

profiles/home/desktop-linux.nix
├── profiles/home/desktop-base.nix
└── modules/home/{firefox,imv,mpv,nautilus,niri,noctalia}
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

External mutable state intentionally outside the repository includes account
passwords, `/var/lib/sbctl`, `~/.ssh/hosts`, and password-manager agent sockets.
Do not attempt to make these declarative unless the user specifically requests a
secrets-management design.

## Neovim Ownership

The Home Manager module is `modules/home/neovim/default.nix`. It is imported by
`profiles/home/development.nix`, so Asgard and both standalone development
outputs receive the same editor setup.

Nix owns the Neovim runtime surface:

- `programs.neovim.package` selects `neovim-unwrapped`; Home Manager creates the
  final wrapped package.
- `programs.neovim.plugins` declares every plugin and Treesitter grammar. There
  is no Lazy.nvim, packer, Mason, or runtime plugin/parser installation.
- `programs.neovim.extraPackages` supplies LSP servers, formatters, search
  tools, and other executables on Neovim's `PATH`.
- `xdg.configFile."nvim/init.lua"` and `xdg.configFile."nvim/lua"` install the
  source under `modules/home/neovim/configs/` into `~/.config/nvim` through
  immutable store-backed links.
- `CONFIG_THEME_FAMILY` is generated from the shared flake theme settings.
- Python and Ruby providers are intentionally disabled.

When adding a plugin, parser, LSP server, formatter, or command, update
`default.nix`; do not assume a host-global executable or runtime download.
Adding a Lua `require` without declaring its plugin in Nix can make startup
fail. `blazingjj` is supplied by `modules/home/jj/default.nix`. The Lua VCS UI
references `lazygit`, but this repository currently does not package it.

## Neovim Startup Order

The entry point is `modules/home/neovim/configs/init.lua`. Startup is eager and
ordered:

```text
config.globals.setup()
options
keymap
autocmds
languages.setup()
plugins.setup()
config.theme.set_colorscheme()
```

The theme is applied last because colorschemes clear generated Heirline and UI
highlight groups.

`configs/lua/plugins/init.lua` then loads:

```text
todo-comments
plugins.theme
plugins.ui
plugins.ui.mini
plugins.ui.neo-tree
plugins.ui.vcs
plugins.ui.heirline
plugins.ui.telescope
plugins.ui.which-key
plugins.ui.snacks
plugins.ui.outline
plugins.ui.nvim-highlight-colors
plugins.ui.gitsigns
plugins.smart
plugins.lsp
plugins.integrations
```

Preserve meaningful ordering:

- Leaders are set before mappings.
- Mini Icons provides `nvim-web-devicons` compatibility before consumers load.
- VCS state is initialized before Heirline and Snacks consume it.
- Blink and LazyDev initialize before LSP capabilities and Lua completion use
  them.
- Theme plugins configure themselves before the final colorscheme application.

## Neovim Lua Map

| Path | Responsibility |
| --- | --- |
| `configs/lua/options.lua` | Editor options, clipboard scheduling, folds, indentation defaults |
| `configs/lua/keymap.lua` | Global mappings and navigation |
| `configs/lua/autocmds.lua` | Yank highlighting and editing-buffer status column |
| `configs/lua/languages/` | Filetype-specific behavior; register new modules in `languages/init.lua` |
| `configs/lua/config/globals.lua` | Leaders and global capability flags |
| `configs/lua/config/lsp_servers.lua` | Declarative LSP server table |
| `configs/lua/config/lsp_keymaps.lua` | `LspAttach` mappings, highlights, and inlay hints |
| `configs/lua/config/theme.lua` | Theme family/variant selection and colorscheme application |
| `configs/lua/config/ui_colors.lua` | Shared StatusLine, WinBar, Dropbar, and message colors |
| `configs/lua/config/util.lua` | Generic command/visual-selection helpers |
| `configs/lua/utils/icons.lua` | Shared icons |
| `configs/lua/plugins/theme/` | Meowsoot, Kanagawa, and Auto Dark Mode setup |
| `configs/lua/plugins/ui/` | Statusline, navigation, pickers, VCS, terminals, symbols, and visual UI |
| `configs/lua/plugins/smart/` | Completion, Treesitter, formatting, and CodeCompanion |
| `configs/lua/plugins/lsp/` | LSP capability merge, executable checks, and server enablement |
| `configs/lua/plugins/integrations/` | Overseer and cross-plugin workflows |

Plugin aggregators expose `M.setup()` and use explicit ordered `require` calls.
Keep plugin-specific state and orchestration under `plugins/<group>/`; use
`config/` for shared editor policy/state, `utils/` for genuinely generic
helpers, and `languages/` for filetype behavior.

## Neovim Subsystems

LSP uses the newer `vim.lsp.config`/`vim.lsp.enable` API. Blink capabilities are
merged into configured servers. Most servers are enabled only when their
resolved command is executable; TypeScript Tools is configured separately.
Server definitions belong in `config/lsp_servers.lua`, mappings in
`config/lsp_keymaps.lua`, package declarations in `default.nix`, and
orchestration in `plugins/lsp/init.lua`.

Completion is configured in `plugins/smart/autocompletion.lua`. Sources are
LazyDev, LSP, paths, LuaSnip, and buffer completion. Formatting is configured in
`plugins/smart/autoformat.lua` through Conform and runs on save. Current chains
include StyLua for Lua, mdsf then rumdl for Markdown, Ruff operations for
Python, Shellharden then shfmt for Zsh, and Prettier as the available HTML
fallback.

UI responsibilities:

- `plugins/ui/heirline.lua`: global statusline presentation only.
- `plugins/ui/vcs.lua`: asynchronous Git/jj root detection, cached repository
  diff counters, identity metadata, refresh events, and VCS terminal selection.
  `.jj` wins in colocated repositories. Git counters are unstaged tracked
  changes; jj counters cover working-copy commit `@`.
- `plugins/ui/snacks.lua`: Snacks input, picker, and terminal mappings.
- `plugins/ui/gitsigns.lua`: current-buffer Git hunks and hunk actions.
- `plugins/ui/telescope.lua`: Ivy-style file/search/buffer/LSP workflows. Its
  project-root helper uses the nearest `.jj` or `.git` marker.
- `plugins/ui/neo-tree.lua`: filesystem, buffers, Git, symbols, nesting, and
  current-file following.
- `plugins/ui/mini.lua`: text objects, surrounds, pairs, indent scope, icons,
  and animation.

Treesitter grammars come from Nix. Do not reintroduce dynamic parser downloads
without redesigning ownership. Nerd Font support is assumed; the portable
desktop profile installs the configured fonts through Home Manager.

## Neovim Validation Before Activation

For Lua-only changes, prepend the checkout to `runtimepath` and explicitly use
the checkout's `init.lua`. Do this on the first attempt; a plain installed
`nvim --headless` tests the previous Home Manager generation.

```bash
CONFIG_THEME_FAMILY=meowsoot \
nvim -n --headless \
  --cmd "set runtimepath^=$PWD/modules/home/neovim/configs" \
  -u "$PWD/modules/home/neovim/configs/init.lua" \
  '+qa'
```

If plugin or executable declarations changed, build/use the newly evaluated
wrapped package instead of the installed one:

```bash
nix build --no-link \
  '.#homeConfigurations."example-user@generic-linux".config.programs.neovim.finalPackage'

CONFIG_THEME_FAMILY=meowsoot \
nix shell \
  '.#homeConfigurations."example-user@generic-linux".config.programs.neovim.finalPackage' \
  -c nvim -n --headless \
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

## Change Discipline

- Make the smallest correct change and preserve explicit module boundaries.
- Do not rewrite generated hardware configuration or template hosts while
  working on unrelated features.
- Do not activate, reboot, enroll keys, partition disks, update lock files, or
  change bookmarks/history as validation.
- Preserve unrelated working-copy changes; this repository may be edited by
  multiple agents or the user concurrently.
- Update this guide when structure, output names, validation commands, or Neovim
  load order materially changes.
