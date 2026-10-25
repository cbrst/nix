# Neovim Module

This directory keeps the Neovim installation and its personal configuration
together.

## Layout

| Path | Role |
| --- | --- |
| `spec.nix` | The editor definition: unwrapped Neovim, every plugin and Treesitter grammar, the tools on `PATH`, and the Lua configuration directory |
| `tools.nix` | External executables on the editor's `PATH`: LSP servers, formatters, debug adapters, and helpers |
| `default.nix` | Home Manager module: feeds `spec.nix` into `programs.neovim`, links the configuration into `~/.config/nvim`, and writes the Mago/rumdl fallback configuration |
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

Because it does not depend on Home Manager, the same definition can be wrapped
in more than one place. Today only `default.nix` uses it. A standalone
`packages.<system>.nvim` flake output, which runs the editor with `nix run` on a
machine without this Home Manager setup, is the planned second user.

Home Manager-only values are passed in as arguments. `claudeCode` is
`programs.claude-code.finalPackage` under Home Manager; a standalone build would
pass `pkgs.claude-code`.

To add something:

- a plugin or grammar: add it to `plugins` in `spec.nix`, then `require` it from
  the Lua configuration;
- a custom or pinned plugin: add a `buildVimPlugin` derivation in the `let`
  block of `spec.nix`, then list it in `plugins`;
- an LSP server, formatter, or debug adapter: add it to `tools.nix`;
- a Home Manager-only value: add an argument to `spec.nix` and pass it from
  `default.nix`.

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
