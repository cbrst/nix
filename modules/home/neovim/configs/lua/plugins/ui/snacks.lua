local M = {}

function M.setup()
	require("snacks").setup({
		-- Keep the general shell-terminal workflow available independently of AI chat.
		input = { enabled = true },
		picker = { enabled = true },
		terminal = { enabled = true },
	})
	vim.keymap.set({ "n", "t" }, "<leader>tt", function()
		require("snacks").terminal.toggle()
	end, { desc = "[T]oggle shell terminal" })
	vim.keymap.set("n", "<leader>tn", function()
		require("snacks").terminal.open()
	end, { desc = "[N]ew shell terminal" })
	vim.keymap.set({ "n", "t" }, "<leader>tf", function()
		require("snacks").terminal.focus()
	end, { desc = "[F]ocus shell terminal" })
	vim.keymap.set("n", "<leader>tg", function()
		-- TODO: make this a custom command or global function.
		-- the same thing is used in heirline as a click action
		local cwd = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
		require("snacks").terminal.toggle("lazygit", {
			cwd = cwd,
			win = {
				style = "terminal",
				position = "bottom",
				height = 0.4,
			},
		})
	end, { desc = "Open Lazy[G]it" })
end

return M
