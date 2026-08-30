local M = {}

function M.setup()
	require("snacks").setup({
		-- Keep the general shell-terminal workflow available independently of AI chat.
		input = { enabled = true },
		picker = { enabled = true },
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
	vim.keymap.set("n", "<leader>gg", function()
		require("plugins.ui.vcs").open(0)
	end, { desc = "VCS status" })
end

return M
