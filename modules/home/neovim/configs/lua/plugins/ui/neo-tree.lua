local M = {}

-- ╭─────────────────────────────╮
-- │ Persistent file exploration │
-- ╰─═══════════════════════════─╯

local additional_nesting_rules = {
	["README.*"] = {
		"AGENTS*",
		"INSTALL*",
	},
}

local function nesting_rules()
	local nr = require("neotree-file-nesting-config").nesting_rules

	for parent, children in pairs(additional_nesting_rules) do
		if nr[parent] and nr[parent].files then
			for _, child in ipairs(children) do
				table.insert(nr[parent].files, child)
			end
		end
	end

	return nr
end

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
			name = {
				use_filtered_colors = true,
				use_git_status_colors = false,
			},
		},
		nesting_rules = nesting_rules(),
		event_handlers = {
			{
				event = "neo_tree_buffer_enter",
				handler = function()
					vim.opt_local.foldcolumn = "0"
				end,
			},
		},
	})

	-- Always reveal the current buffer so the tree opens in the relevant directory.
	vim.keymap.set("n", "\\", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "Browse files near current buffer" })
	vim.keymap.set("n", "<leader>op", "<cmd>Neotree toggle reveal_force_cwd<cr>", { desc = "Project sidebar" })
end

return M
