---
title: Emacs
description: A Nix-owned Emacs environment that mirrors the Neovim setup.
sidebar:
  order: 4
---

[`modules/home/emacs/`](https://github.com/cbrst/nix/tree/main/modules/home/emacs)
is a complete Emacs environment designed to sit next to
[Neovim](/nix/modules/home/neovim/) with the same keys, tools, and theme.

:::note
The module is currently commented out of the development profile, so no host
installs it. Re-enable it by uncommenting its import in
`profiles/home/development.nix`.
:::

## Design

- **Same structure as Neovim.** Start-up loads globals, options, keymaps,
  buffer hooks, languages, plugins, and finally the theme, in that order.
- **Nix owns everything.** Packages, runtimes, language servers, formatters,
  debuggers, and Tree-sitter grammars are declared in `default.nix`. Package
  archives and automatic LSP downloads are disabled, and Nix-provided
  autoloads are activated locally.
- **Generated settings.** Nix writes `nix-settings.el` with the fonts, both
  theme palettes, grammar paths, executable paths, and debugger locations.
- **Shared tools.** The external servers and formatters come from the same
  [editor tools](/nix/modules/home/editor-tools/) list Neovim uses.
- **Not the default editor.** The module does not change `EDITOR`, `VISUAL`, or
  the Git and jj editors, and does not start an Emacs daemon.

## Features

Evil with `Space` as the leader and which-key after 300 ms; project-aware file,
buffer, and grep pickers; a file tree and symbol sidebar; LSP navigation,
actions, and formatting; terminals; Git and jj hunks and status (Blazingjj in jj
repositories, Lazygit in Git ones); Dape debugging with the same adapters as
Neovim; project tasks; and an OpenCode ACP chat under `SPC o l`.

The full key table is in the module's
[README](https://github.com/cbrst/nix/blob/main/modules/home/emacs/README.md).

## Tests

`tests/run-tests.el` contains source and behavioural tests. They start
temporary live language servers, Git and jj fixtures, formatter chains, and
terminal input against the newly built `programs.emacs.finalPackage` with the
generated settings passed through `EMACS_NIX_SETTINGS`. They do not test
authenticated ACP requests or every debugger session. Commands and known
differences from Neovim are documented in the README.
