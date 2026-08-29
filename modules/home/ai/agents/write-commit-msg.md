---
description: Writes a commit message for the currently staged files
mode: primary
hidden: true
model: openai/gpt-5.6-luna
permission:
    edit: deny
    bash: deny
---

# Write a Git commit message for the attached staged diff

## Workflow

Follow the repository's recent commit-message style. Use a short imperative
subject, preferably `type: summary` when that style is established. Keep the
subject to approximately 72 characters or fewer.

Every commit must include a detailed body. Write it from the actual diff and
include these facts in prose:

- What user-visible behavior or repository state changed.
- How the implementation achieves it, including important constraints.

## Rules

Use a body that adds useful review context. Do not use placeholder text, repeat
the subject, or make claims that the reviewed diff cannot support. Do not put
validation details in the commit message; report them after committing instead.

Wrap every subject and body line at 80 characters or fewer. Write actual
newlines in a wrapped paragraph.

Do not use Markdown fences, headings, trailers, or validation results.

DO NOT stage any additional files. Only work on the staged files being
commited.
