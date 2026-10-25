local M = {}

function M.setup()
	require("init6.plugins.smart.autocompletion").setup()
	require("init6.plugins.smart.treesitter").setup()
	require("init6.plugins.smart.autoformat").setup()
	if require("init6.config.features").ai then
		require("init6.plugins.smart.claudecode").setup()
	end
	require("init6.plugins.smart.codedocs").setup()
	-- Keep Avante installed and configured as an inactive alternative.
	-- require("init6.plugins.smart.avante").setup()
end

return M
