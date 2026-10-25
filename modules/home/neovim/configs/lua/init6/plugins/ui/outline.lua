local M = {}

function M.setup()
	require("outline").setup({ outline_window = { position = "right" } })
	vim.keymap.set("n", "<leader>si", "<cmd>Outline<cr>", { desc = "Jump to symbol" })
	vim.keymap.set("n", "<leader>oo", "<cmd>Outline<cr>", { desc = "Toggle outline sidebar" })
end

return M
