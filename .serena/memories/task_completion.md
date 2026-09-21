# Completion checks
- Run the relevant formatter/parser, then `jj diff --stat` and `git diff --check`.
- Nix/module changes: evaluate or no-link build the relevant flake output; never activate unless requested.
- Lua: `nix shell nixpkgs#stylua -c stylua --check <changed.lua files>`.
- Neovim Lua source test uses checkout runtime/init, not installed generation: `CONFIG_THEME_FAMILY=meowsoot nvim -n --headless --cmd \"set runtimepath^=$PWD/modules/home/neovim/configs\" -u \"$PWD/modules/home/neovim/configs/init.lua\" '+qa'`.
- If plugin/executable declarations changed, first build and run the newly evaluated wrapped Neovim package as documented in `mem:neovim/core`.