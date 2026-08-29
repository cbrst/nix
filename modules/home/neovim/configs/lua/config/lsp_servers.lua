-- ┌──────────────────────────┐
-- │ Server-specific settings │
-- └──────────────────────────┘
return {
	bashls = {},
	emmet_language_server = {
		cmd = { "emmet-language-server", "--stdio" },
		filetypes = {
			"css",
			"eruby",
			"html",
			"javascript",
			"javascriptreact",
			"less",
			"sass",
			"scss",
			"pug",
			"typescriptreact",
		},
		init_options = {
			-- Keep abbreviation suggestions visible in Blink's completion menu.
			showAbbreviationSuggestions = true,
			showExpandedAbbreviation = "always",
		},
	},
	jsonls = {
		cmd = { "vscode-json-language-server", "--stdio" },
	},
	lua_ls = {
		settings = {
			Lua = {
				-- Replace a call expression with the selected Lua snippet.
				completion = { callSnippet = "Replace" },
			},
		},
	},
	nil_ls = {},
	phpactor = {},
	yamlls = {
		cmd = { "yaml-language-server", "--stdio" },
	},
	zshcs = {
		cmd = { "zshcs" },
		filetypes = { "zsh" },
		root_markers = { ".git" },
		settings = {
			zshcs = {
				experimental = {
					diagnostics = true,
					hover = true,
				},
			},
		},
	},
	zuban = {},
}
