local M = {}

M.setup = function()
	require("codedocs").setup({})
	vim.keymap.set("n", "<leader>cA", "<cmd>Codedocs<CR>", { desc = "Annotate" })
end

return M
