local M = {}

-- ┌──────────────────────────────────────┐
-- │ Legacy Vim syntax groups             │
-- └──────────────────────────────────────┘
function M.get(c)
	return {
		Comment = { fg = c.comment, italic = true },
		SpecialComment = { fg = c.fg_muted, bold = true, italic = true },

		Constant = { fg = c.constant },
		String = { fg = c.string },
		Character = { fg = c.string },
		Number = { fg = c.number },
		Boolean = { fg = c.constant },
		Float = "Number",

		Identifier = { fg = c.fg },
		Function = { fg = c.func },

		Statement = { fg = c.keyword },
		Conditional = "Statement",
		Repeat = "Statement",
		Label = "Statement",
		Operator = { fg = c.operator },
		Keyword = { fg = c.keyword },
		Exception = "Statement",

		PreProc = { fg = c.keyword },
		Include = "PreProc",
		Define = "PreProc",
		Macro = { fg = c.constant },
		PreCondit = "PreProc",

		Type = { fg = c.type },
		StorageClass = { fg = c.keyword },
		Structure = "Type",
		Typedef = "Type",

		Special = { fg = c.special },
		SpecialChar = { fg = c.escape },
		Tag = { fg = c.keyword },
		Delimiter = { fg = c.punctuation },
		Debug = { fg = c.warning },

		Underlined = { underline = true },
		Bold = { bold = true },
		Italic = { italic = true },
		Ignore = { fg = c.fg_faint },
		Error = { fg = c.error },
		Todo = { fg = c.bg, bg = c.accent5, bold = true },

		-- Vim's own syntax files for Markdown and help.
		markdownCode = { fg = c.string },
		markdownCodeBlock = { fg = c.string },
		markdownEscape = { fg = c.escape },
		markdownH1 = { fg = c.rainbow[1], bold = true },
		markdownH2 = { fg = c.rainbow[2], bold = true },
		markdownH3 = { fg = c.rainbow[3], bold = true },
		markdownH4 = { fg = c.rainbow[4], bold = true },
		markdownH5 = { fg = c.rainbow[5], bold = true },
		markdownH6 = { fg = c.rainbow[6], bold = true },
		markdownLinkText = { fg = c.link, underline = true },
		markdownUrl = { fg = c.fg_muted, underline = true },
		helpHyperTextJump = { fg = c.link },
		helpHyperTextEntry = { fg = c.func, bold = true },
		helpCommand = { fg = c.string },
		helpExample = { fg = c.string },
		helpOption = { fg = c.accent3 },
	}
end

return M
