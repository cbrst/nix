local M = {}

function M.setup()
	require("plugins.smart.autocompletion").setup()
	require("plugins.smart.treesitter").setup()
	require("plugins.smart.autoformat").setup()
	require("plugins.smart.opencode").setup()
	require("plugins.smart.codedocs").setup()
	-- Keep Avante installed and configured while opencode.nvim is being evaluated.
	-- require("plugins.smart.avante").setup()
end

return M
