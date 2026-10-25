local M = {}

function M.setup()
	require("auto-dark-mode").setup({
		set_dark_mode = function()
			require("init6.config.theme").set_colorscheme("dark")
		end,
		set_light_mode = function()
			require("init6.config.theme").set_colorscheme("light")
		end,
	})
end

return M
