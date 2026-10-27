local M = {}

-- ┌────────────────────────────┐
-- │ Eager plugin configuration │
-- └────────────────────────────┘
function M.setup()
	-- These Vim plugins configure themselves when their runtime files are sourced.
	require("todo-comments").setup({ signs = false })

	-- Set up foundational UI components before plugins that consume their APIs.
	require("init6.plugins.theme").setup()
	require("init6.plugins.ui").setup()
	require("init6.plugins.ui.mini").setup()
	require("init6.plugins.ui.neo-tree").setup()
	require("init6.plugins.ui.vcs").setup()
	require("init6.plugins.ui.heirline").setup()
	require("init6.plugins.ui.telescope").setup()
	require("init6.plugins.ui.remote").setup()
	require("init6.plugins.ui.which-key").setup()
	require("init6.plugins.ui.snacks").setup()
	require("init6.plugins.ui.outline").setup()
	require("init6.plugins.ui.nvim-highlight-colors").setup()
	require("init6.plugins.ui.gitsigns").setup()
	if require("init6.config.features").debug then
		require("init6.plugins.debug").setup()
	end

	-- Blink must initialize before LSP capabilities are derived from it.
	require("init6.plugins.smart").setup()
	require("init6.plugins.lsp").setup()
	require("init6.plugins.integrations").setup()
end

return M
