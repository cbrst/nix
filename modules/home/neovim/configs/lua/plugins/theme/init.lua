local M = {}

function M.setup()
	-- The `flake` colorscheme needs no setup; init.lua applies it last.
	require("plugins.theme.auto-dark-mode").setup()
end

return M
