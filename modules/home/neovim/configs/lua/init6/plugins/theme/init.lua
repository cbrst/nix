local M = {}

function M.setup()
	-- The `init6` colorscheme needs no setup; init.lua applies it last.
	require("init6.plugins.theme.auto-dark-mode").setup()
end

return M
