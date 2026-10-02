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
						["<a-o>"] = { "claudecode_send", mode = { "n", "i" } },
					},
				},
			},
			actions = {
				claudecode_send = function(picker)
					local claudecode = require("claudecode")
					local path = require("snacks").picker.util.path

					for _, item in ipairs(picker:selected({ fallback = true })) do
						if item.file then
							local start_line = item.pos and item.pos[1] and item.pos[1] - 1 or nil
							local end_line = item.end_pos and item.end_pos[1] and item.end_pos[1] - 1 or start_line
							claudecode.send_at_mention(path(item), start_line, end_line, "SnacksPicker")
						end
					end
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
