local M = {}

function M.setup()
	require("plugins.smart.autocompletion").setup()
	require("plugins.smart.treesitter").setup()
	require("plugins.smart.autoformat").setup()
	require("plugins.smart.claudecode").setup()
	require("plugins.smart.codedocs").setup()
	-- Keep Avante installed and configured as an inactive alternative.
	-- require("plugins.smart.avante").setup()
end

return M
