local M = {}

function M.setup()
	require("plugins.smart.autocompletion").setup()
	require("plugins.smart.treesitter").setup()
	require("plugins.smart.autoformat").setup()
	require("plugins.smart.avante").setup()
end

return M
