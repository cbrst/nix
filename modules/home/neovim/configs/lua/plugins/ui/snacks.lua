local M = {}

function M.setup()
	require("snacks").setup({
		-- Keep the general shell-terminal workflow available independently of AI chat.
		input = { enabled = true },
		picker = {
			enabled = true,
			win = {
				input = {
					keys = {
						["<a-o>"] = { "opencode_send", mode = { "n", "i" } },
					},
				},
			},
			actions = {
				opencode_send = function(picker)
					local items = vim.tbl_map(function(item)
						return item.file
								and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
							or item.text
					end, picker:selected({ fallback = true }))

					require("opencode").prompt(table.concat(items, ", ") .. " ")
				end,
			},
		},
		terminal = { enabled = true },
	})
	vim.keymap.set({ "n", "t" }, "<leader>ot", function()
		require("snacks").terminal.toggle()
	end, { desc = "Toggle terminal popup" })
	vim.keymap.set("n", "<leader>oT", function()
		require("snacks").terminal.open()
	end, { desc = "Open terminal here" })
	vim.keymap.set({ "n", "t" }, "<leader>of", function()
		require("snacks").terminal.focus()
	end, { desc = "Focus terminal" })
end

return M
