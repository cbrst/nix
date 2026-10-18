---
title: AI tooling
description: Claude Code, its agents and skills, Serena, RTK, and the inactive OpenCode setup.
sidebar:
  order: 6
---

[`modules/home/ai/`](https://github.com/cbrst/nix/tree/main/modules/home/ai)
configures AI coding tools. It is part of the
[development profile](/nix/profiles/home/#development).

## Claude Code

Home Manager installs and configures [Claude Code](https://claude.com/claude-code):

- **Settings** default to medium reasoning effort and disable the commit and
  pull request attribution lines. `settings.json` stays writable
  (`mutableSettings`), so changes made with `/config` persist; the declared keys
  are merged over it on every activation.
- **Global context** (`~/.claude/CLAUDE.md`) tells every session to check for a
  jj repository before using Git commands. In a colocated repository Git shows
  a detached `HEAD`, which is expected, and the `idiomatic-jj` skill should be
  loaded instead of falling back to Git habits.
- **MCP integration** shares the MCP servers declared in `programs.mcp`.
- **RTK hook.** A `PreToolUse` hook on the Bash tool runs RTK's rewrite script,
  which compresses command output before it reaches the model.

### Agents

| Agent | Purpose |
| --- | --- |
| `dennis` | Designs, implements, visually inspects, and iteratively improves web interfaces |
| `write-commit-msg` | Writes a commit message from a supplied diff. Runs on Haiku with no tools and no permission prompts; used by the [commit-message hook](/nix/workflows/commit-messages/) |

The prompts are Markdown files in `agents/`; Nix wraps them with frontmatter for
each tool.

### Skills

Everything in `skills/` is installed as Claude Code skills, including:

- `idiomatic-jj`: Jujutsu mental models and safe command choices.
- `group-unstaged-commits`: splitting working-copy changes into coherent commits.
- A set of front-end design skills (brand kits, image-to-code, minimalist,
  brutalist, motion, and web interface guidelines) used together with `dennis`.

## Serena

The [Serena](https://github.com/oraios/serena) MCP server provides
symbol-level code navigation and editing. It is declared once in
`programs.mcp` and runs over stdio in IDE context, picking the project from the
working directory, without opening its web dashboard.

## RTK

[RTK](https://github.com/rtk-ai/rtk) is built locally from a pinned source (see
[Flake inputs](/nix/architecture/flake-inputs/#local-packages)). Besides the
Claude Code hook, its OpenCode plugin is linked into `~/.config/opencode` by
Home Manager rather than with `rtk init`.

## Playwright

`playwright` and `playwright-test` are installed for browser-based workflows,
such as `dennis` inspecting a page it built.

## OpenCode (inactive)

OpenCode is fully declared but disabled. Its configuration, including a theme
generated from the shared palette, the same agents and skills, and a session
picker (`opencode-fzf`) in the shell, is kept so it can be switched back on.
