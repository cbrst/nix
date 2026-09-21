# Nix configuration
- Editable source is this flake checkout; installed generations and `/nix/store` outputs are stale until built/activated.
- Never activate (`nixos-rebuild switch`, `home-manager switch`) unless explicitly requested.
- Preserve host-specific values under `hosts/`, user state versions, secrets, and unrelated working-copy edits.
- Colocated jj/Git repository: inspect with `jj status`/`jj diff`; do not alter history/bookmarks unless requested.
- Architecture and outputs: `mem:tech_stack`; Neovim ownership/startup: `mem:neovim/core`; validation: `mem:task_completion`; conventions: `mem:conventions`.