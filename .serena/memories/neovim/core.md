# Neovim
- Home Manager owner: `modules/home/neovim/default.nix`; Lua source: `modules/home/neovim/configs/`; imported by `profiles/home/development.nix`.
- Nix declares every plugin/grammar and wrapped executable. `xdg.configFile` links checkout source into generated configuration.
- Startup order: globals -> options -> keymap -> autocmds -> languages -> plugins -> final colorscheme. Preserve ordering dependencies: Mini Icons before consumers; VCS before Heirline/Snacks; Blink/LazyDev before LSP.
- Plugin declarations changed: build `'.#homeConfigurations.\"example-user@generic-linux\".config.programs.neovim.finalPackage'`, then run that package with checkout runtime/init; do not test installed Neovim first.
- LSP uses `vim.lsp.config`/`vim.lsp.enable`; server policy in `config/lsp_servers.lua`, mappings in `config/lsp_keymaps.lua`, orchestration in `plugins/lsp/init.lua`.
- Treesitter grammars and all tools remain Nix-owned; no Lazy/Mason/runtime downloads.