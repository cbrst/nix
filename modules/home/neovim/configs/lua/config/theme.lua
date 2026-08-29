local M = {}

-- ┌────────────────────────────┐
-- │ Theme family selection │
-- └────────────────────────────┘
function M.set_colorscheme(variant)
	variant = variant or vim.opt.background:get()
	vim.api.nvim_set_option_value("background", variant, {})
	local families = {
		["meowsoot"] = { light = "meowsoot-dawn", dark = "meowsoot" },
		["kanagawa"] = { light = "kanagawa-lotus", dark = "kanagawa-wave" },
		["monokai-pro"] = { light = "monokai-pro-light", dark = "monokai-pro-spectrum" },
	}
	local family = families[vim.env.CONFIG_THEME_FAMILY] or families.meowsoot
	local colorscheme = family[variant]
	vim.cmd.colorscheme(colorscheme)
	-- The colorscheme clears generated Heirline groups, so rebuild them before rendering.
	require("heirline.utils").on_colorscheme()
	-- Reapply shared UI surfaces after the colorscheme resets status and window highlights.
	require("config.ui_colors").apply()
end

return M
