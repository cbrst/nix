local M = {}

function M.setup()
	require("kanagawa").setup({
		background = {
			dark = "wave",
			light = "lotus",
		},
		overrides = function(colors)
			local ui = colors.theme.ui
			return {
				MiniIndentscopeSymbol = { fg = ui.nontext, nocombine = true },
				NeoTreeIndentMarker = { fg = ui.nontext },
				FoldColumn = { fg = ui.nontext, bg = ui.bg },
				NeoTreeRootName = { fg = ui.fg, bold = true },
			}
		end,
	})
end

return M
