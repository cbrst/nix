local M = {}

-- ┌─────────────────────┐
-- │ Avante and OpenCode │
-- └─────────────────────┘
function M.setup()
	--- @diagnostic disable: missing-fields
	--- defaulted fields are not marked optional upstream
	require("avante").setup({
		debug = false,
		provider = "opencode",
		mode = "agentic",
		behaviour = {
			auto_focus_sidebar = true,
			auto_suggestions = false,
			auto_set_highlight_group = true,
			auto_set_keymaps = false,
			auto_apply_diff_after_generation = false,
			minimize_diff = true,
			enable_token_counting = true,
			auto_add_current_file = true,
		},
		input = {
			provider = "snacks",
		},
		windows = {
			sidebar_header = {
				include_model = true,
			},
		},
	})
	--- @diagnostic enable: missing-fields

	local api = require("avante.api")

	vim.keymap.set("n", "<leader>oll", function()
		require("avante").toggle()
	end, { desc = "Open AI chat" })
	vim.keymap.set("x", "<leader>ola", api.ask, { desc = "Add selection to AI context" })
	vim.keymap.set("n", "<leader>olm", api.select_acp_mode, { desc = "Select AI mode" })
	vim.keymap.set("n", "<leader>olM", api.select_acp_model, { desc = "Select AI model" })
	vim.keymap.set("n", "<leader>olr", function()
		local line = vim.api.nvim_win_get_cursor(0)[1]
		api.edit(nil, line, line)
	end, { desc = "Rewrite line with AI" })
	vim.keymap.set("x", "<leader>olr", api.edit, { desc = "Rewrite selection with AI" })
	vim.keymap.set("n", "<leader>olR", function()
		api.ask({
			new_chat = true,
			question = "Review the current changes for bugs, regressions, and missing tests. Report findings first, ordered by severity, with file and line references.",
		})
	end, { desc = "Review code with AI" })
end

return M
