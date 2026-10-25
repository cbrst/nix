local M = {}

function M.setup()
	require("overseer").setup({})
	vim.keymap.set("n", "<leader>cc", "<cmd>OverseerRun<cr>", { desc = "Compile/run task" })
	vim.keymap.set("n", "<leader>cC", "<cmd>OverseerToggle<cr>", { desc = "Toggle task list" })
end

return M
