---
title: Version control
description: Git and Jujutsu configuration, aliases, completion, and terminal UIs.
sidebar:
  order: 2
---

[`modules/home/vcs/`](https://github.com/cbrst/nix/tree/main/modules/home/vcs)
owns Git, [Jujutsu](https://github.com/jj-vcs/jj) (jj), and their terminal
interfaces. It is part of the [minimal profile](/nix/profiles/home/#minimal).
For how these pieces are used day to day, see
[Working with jj](/nix/workflows/jujutsu/).

## Git

Git uses the shared identity and rebases on `git pull`. A `prepare-commit-msg`
hook drafts commit messages with Claude Code; see
[Commit message drafting](/nix/workflows/commit-messages/).

## Jujutsu

jj uses the same identity. Its editor is a small wrapper,
`jj-commit-editor`, which runs the same drafting hook in jj mode and then opens
`$EDITOR`. The draft description template includes the diff
(`builtin_draft_commit_description_with_diff`), which gives the hook something
to summarise.

### Aliases

| Alias | What it does |
| --- | --- |
| `jj logn` | Shows `trunk()..@` plus the parent of that range: a compact view of local, unpublished work |
| `jj pull` | Fetches from the Git remote, then rebases the mutable stack rooted at `roots(trunk()..stack(@))` onto `trunk()` |
| `jj sync` | Runs `pull`, then pushes all changed bookmarks with `--allow-new` so new bookmarks publish on their first push |

`pull` and `sync` run through `jj util exec` with `sh -c`, so the fetch,
rebase, and push run as one sequence that stops at the first failure. The
rebase source only moves the unpushed stack and leaves already-merged history
alone.

## Zsh completion for jj

jj's dynamic completer only offers changed paths and matches them by literal
prefix, so a partial path such as `m/h/f` did not expand. The module adds a
wrapper, `_jj_with_files`, that loads jj's completer on first use, runs it, and
falls back to Zsh's `_files` when it returns no matches and the current word is
not a flag. The block is ordered at 1010 so it runs after the
[shell module's](/nix/modules/home/shell/) initialisation.

## Terminal interfaces

- **LazyGit**, with shell integration, for Git repositories.
- **BlazingJJ**, for jj repositories.

Both are for shell use; Neovim has its own [VCS interface](/nix/modules/home/neovim/#version-control).
