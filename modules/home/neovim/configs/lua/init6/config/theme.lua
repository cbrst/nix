local M = {}

-- ┌────────────────────────────┐
-- │ init6 palette colorscheme  │
-- └────────────────────────────┘
function M.set_colorscheme(variant)
	variant = variant or vim.opt.background:get()
	vim.api.nvim_set_option_value("background", variant, {})
	-- The `init6` scheme reads the matching variant of the shared Nix palette.
	vim.cmd.colorscheme("init6")
	-- The colorscheme clears generated Heirline groups, so rebuild them before rendering.
	require("heirline.utils").on_colorscheme()
	-- Reapply shared UI surfaces after the colorscheme resets status and window highlights.
	require("init6.config.ui_colors").apply()
end

return M
