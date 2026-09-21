# Conventions
- Make the smallest correct change; preserve module boundaries: hosts=machine values, profiles=role bundles, modules=reusable features, users=person-specific state.
- Nix owns editor plugins, parsers, servers, formatters, and executables; no runtime downloads.
- Default to ASCII; comments explain non-obvious policy only.
- Neovim plugin group aggregators expose `M.setup()` and use explicit ordered `require` calls.
- Lua plugin orchestration belongs under `plugins/<group>/`; shared policy/state under `config/`; generic helpers under `utils/`; filetype behavior under `languages/`.
- More Neovim invariants: `mem:neovim/core`.