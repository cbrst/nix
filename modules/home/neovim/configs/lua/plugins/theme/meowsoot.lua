local M = {}

function M.setup()
	require("meowsoot").setup({
		plugins = { all = true },
		on_highlights = function(hl, colors)
			local guide = require("meowsoot.util").blend(colors.indent, 0.5, colors.bg)

			hl.MiniIndentscopeSymbol = { fg = guide, nocombine = true }
			hl.NeoTreeIndentMarker = { fg = guide }
			hl.FoldColumn = { fg = guide, bg = colors.bg }
			hl.NeoTreeRootName = { fg = colors.fg, bold = true }
		end,
	})
end

return M
