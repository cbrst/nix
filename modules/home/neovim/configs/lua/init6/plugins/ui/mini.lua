local M = {}

-- ┌─────────────────────────────────────┐
-- │ Cohesive editor primitives          │
-- └─────────────────────────────────────┘
function M.setup()
	-- Textobjects and surroundings retain the established editing workflow.
	require("mini.ai").setup({ n_lines = 500 })
	require("mini.surround").setup()

	require("mini.operators").setup({
		replace = { prefix = "" },
	})

	-- Typed pairs complement Blink's completion-time function-call brackets.
	require("mini.pairs").setup()
	require("mini.indentscope").setup({
		options = { try_as_border = true },
		symbol = "│",
	})

	-- Provide one icon source, including a devicons-compatible API for Telescope.
	require("mini.icons").setup({
		style = vim.g.have_nerd_font and "glyph" or "ascii",
	})
	MiniIcons.mock_nvim_web_devicons()

	-- Animations
	require("mini.animate").setup({
		scroll = { enable = true },
		resize = { enable = true },
		open = { enable = true },
		close = { enable = true },
	})
end

return M
