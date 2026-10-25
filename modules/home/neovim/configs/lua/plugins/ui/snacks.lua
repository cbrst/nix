local M = {}

function M.setup()
	local dashboard = require("plugins.ui.dashboard")
	dashboard.setup()

	-- Sending picker items to Claude needs claudecode.nvim, which is only
	-- installed with the `ai` feature.
	local ai_keys, ai_actions = {}, {}
	if require("config.features").ai then
		ai_keys["<a-o>"] = { "claudecode_send", mode = { "n", "i" } }
		ai_actions.claudecode_send = function(picker)
			local claudecode = require("claudecode")
			local path = require("snacks").picker.util.path

			for _, item in ipairs(picker:selected({ fallback = true })) do
				if item.file then
					local start_line = item.pos and item.pos[1] and item.pos[1] - 1 or nil
					local end_line = item.end_pos and item.end_pos[1] and item.end_pos[1] - 1 or start_line
					claudecode.send_at_mention(path(item), start_line, end_line, "SnacksPicker")
				end
			end
		end
	end

	require("snacks").setup({
		dashboard = dashboard.opts(),
		dim = {},
		-- Keep the general shell-terminal workflow available independently of AI chat.
		input = { enabled = true },
		picker = {
			enabled = true,
			win = {
				input = {
					keys = ai_keys,
				},
			},
			actions = ai_actions,
		},
		terminal = { enabled = true },
	})
	-- Dimming has no `enabled` option; it only starts through enable().
	require("snacks").dim.enable()
	require("snacks").toggle.dim():map("<leader>td")
	-- Normal mode only: a "t" (terminal-mode) binding here would eat the
	-- literal "<space>t"/"<space>f" keystrokes typed into any terminal buffer
	-- (e.g. Claude Code's prompt), firing this instead of sending them through.
	vim.keymap.set("n", "<leader>ot", function()
		require("snacks").terminal.toggle()
	end, { desc = "Toggle terminal popup" })
	vim.keymap.set("n", "<leader>oT", function()
		require("snacks").terminal.open()
	end, { desc = "Open terminal here" })
	vim.keymap.set("n", "<leader>of", function()
		require("snacks").terminal.focus()
	end, { desc = "Focus terminal" })
end

return M
