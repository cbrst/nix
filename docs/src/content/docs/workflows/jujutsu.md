---
title: Working with jj
description: How this repository and the configured tools use Jujutsu.
sidebar:
  order: 1
---

This repository, like most of the user's repositories, is managed with
[Jujutsu](https://github.com/jj-vcs/jj) (jj) and colocated with Git. Git sees a
detached `HEAD`; that is expected.

## Mental model

- The working copy is a commit, `@`. There is no staging area; edits are part of
  `@` automatically.
- After `jj commit`, the finished change is `@-` and `@` is a new empty change.
- Bookmarks (jj's branches) do not move by themselves. `main` is moved
  explicitly or by the `sync` alias's push.

## Everyday commands

```bash
jj status          # what changed in @
jj diff            # the diff of @
jj logn            # local, unpublished work on top of trunk
jj commit          # describe @ (with an AI-drafted message) and start a new change
jj pull            # fetch, then rebase the local stack onto trunk
jj sync            # pull, then push changed bookmarks
```

`logn`, `pull`, and `sync` are aliases defined by the
[VCS module](/nix/modules/home/vcs/#aliases).

## Tooling that understands jj

| Tool | jj support |
| --- | --- |
| Zsh | Path completion falls back to files, so `jj diff m/h/f<Tab>` expands |
| Prompt | Oh My Posh shows a jj segment with the change ID |
| Neovim | NeoJJ for status, commit, log, and more; jj diff counters in the statusline |
| Emacs | Blazingjj from `SPC g g` |
| Shell | BlazingJJ terminal UI |
| Claude Code | Global context and the `idiomatic-jj` skill steer it to jj commands |
| Commit messages | The [drafting hook](/nix/workflows/commit-messages/) works in jj's editor |
