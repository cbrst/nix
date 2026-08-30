local M = {}

-- ╭─────────────────────────────╮
-- │ Persistent file exploration │
-- ╰─═══════════════════════════─╯
function M.setup()
	require("neo-tree").setup({
		sources = {
			"filesystem",
			"buffers",
			"git_status",
			"document_symbols",
		},
		close_if_last_window = true,
		enable_cursor_hijack = true,
		use_popups_for_input = false,
		filesystem = {
			follow_current_file = { enabled = true },
			filtered_items = {
				show_hidden_count = false,
				never_show = {
					".DS_Store",
				},
			},
		},
		default_component_configs = {
			indent = {
				with_expanders = true,
				expander_collapsed = "",
				expander_expanded = "",
			},
		},
		nesting_rules = require("neotree-file-nesting-config").nesting_rules,
	})

	-- Always reveal the current buffer so the tree opens in the relevant directory.
	vim.keymap.set("n", "\\", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "Browse files near current buffer" })
	vim.keymap.set("n", "<leader>op", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "Project sidebar" })
end

return M
