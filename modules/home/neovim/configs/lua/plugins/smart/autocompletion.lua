local M = {}

function M.setup()
	-- LuaSnip is built by Nix, so no runtime make invocation is required.
	require("luasnip").config.setup({})
	require("blink.cmp").setup({
		keymap = {
			preset = "default",
			["<C-l>"] = { "snippet_forward", "fallback" },
			["<C-h>"] = { "snippet_backward", "fallback" },
		},
		appearance = {
			nerd_font_variant = "normal",
		},
		completion = {
			menu = { border = "rounded" },
			documentation = {
				auto_show = true,
				border = "rounded",
			},
			-- Replace the former nvim-cmp/autopairs function-call integration.
			accept = {
				auto_brackets = { enabled = true },
			},
		},
		cmdline = {
			keymap = { preset = "inherit" },
			completion = {
				menu = { auto_show = true },
			},
		},
		signature = {
			window = { border = "rounded" },
		},
		snippets = { preset = "luasnip" },
		sources = {
			default = {
				"lazydev",
				"lsp",
				"path",
				"snippets",
				"buffer",
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	})
end

return M
