local M = {}

-- ┌──────────────────────────────────────┐
-- │ Treesitter captures                  │
-- └──────────────────────────────────────┘
-- Covers :h treesitter-highlight-groups; unlisted language suffixes such as
-- `@function.lua` fall back to these.
function M.get(c)
	local groups = {
		["@variable"] = { fg = c.fg },
		["@variable.builtin"] = { fg = c.builtin, italic = true },
		["@variable.parameter"] = { fg = c.parameter },
		["@variable.parameter.builtin"] = { fg = c.parameter, italic = true },
		["@variable.member"] = { fg = c.property },

		["@constant"] = "Constant",
		["@constant.builtin"] = { fg = c.constant, italic = true },
		["@constant.macro"] = "Macro",

		["@module"] = { fg = c.module },
		["@module.builtin"] = { fg = c.module, italic = true },
		["@label"] = { fg = c.keyword },

		["@string"] = "String",
		["@string.documentation"] = { fg = c.comment },
		["@string.regexp"] = { fg = c.regex },
		["@string.escape"] = { fg = c.escape },
		["@string.special"] = { fg = c.escape },
		["@string.special.symbol"] = { fg = c.constant },
		["@string.special.path"] = { fg = c.link },
		["@string.special.url"] = { fg = c.link, underline = true },

		["@character"] = "Character",
		["@character.special"] = { fg = c.escape },

		["@boolean"] = "Boolean",
		["@number"] = "Number",
		["@number.float"] = "Number",

		["@type"] = "Type",
		["@type.builtin"] = { fg = c.type, italic = true },
		["@type.definition"] = "Type",

		["@attribute"] = { fg = c.attribute },
		["@attribute.builtin"] = { fg = c.attribute, italic = true },
		["@property"] = { fg = c.property },

		["@function"] = "Function",
		["@function.builtin"] = { fg = c.func, italic = true },
		["@function.call"] = "Function",
		["@function.macro"] = "Macro",
		["@function.method"] = "Function",
		["@function.method.call"] = "Function",
		["@constructor"] = { fg = c.type },
		["@operator"] = "Operator",

		["@keyword"] = "Keyword",
		["@keyword.coroutine"] = { fg = c.keyword_control },
		["@keyword.function"] = "Keyword",
		["@keyword.operator"] = { fg = c.keyword },
		["@keyword.import"] = "Include",
		["@keyword.type"] = "Keyword",
		["@keyword.modifier"] = "Keyword",
		["@keyword.repeat"] = "Repeat",
		["@keyword.return"] = { fg = c.keyword_control, italic = true },
		["@keyword.debug"] = "Debug",
		["@keyword.exception"] = "Exception",
		["@keyword.conditional"] = "Conditional",
		["@keyword.conditional.ternary"] = "Operator",
		["@keyword.directive"] = "PreProc",
		["@keyword.directive.define"] = "Define",

		["@punctuation.delimiter"] = "Delimiter",
		["@punctuation.bracket"] = { fg = c.punctuation },
		["@punctuation.special"] = { fg = c.escape },
		-- Brackets whose pair is on another line (`plugins/ui/block-brackets.lua`).
		-- Same shade as the indent guides.
		Init6BlockBracket = { fg = c.guide },

		["@comment"] = "Comment",
		["@comment.documentation"] = "Comment",
		["@comment.error"] = { fg = c.bg, bg = c.error, bold = true },
		["@comment.warning"] = { fg = c.bg, bg = c.warning, bold = true },
		["@comment.todo"] = "Todo",
		["@comment.note"] = { fg = c.bg, bg = c.info, bold = true },

		["@markup.strong"] = { bold = true },
		["@markup.italic"] = { italic = true },
		["@markup.strikethrough"] = { strikethrough = true },
		["@markup.underline"] = { underline = true },
		["@markup.heading"] = { fg = c.accent, bold = true },
		["@markup.quote"] = { fg = c.fg_muted, italic = true },
		["@markup.math"] = { fg = c.accent3 },
		["@markup.link"] = { fg = c.link },
		["@markup.link.label"] = { fg = c.link },
		["@markup.link.url"] = { fg = c.fg_muted, underline = true },
		["@markup.raw"] = { fg = c.string },
		["@markup.raw.block"] = { fg = c.fg },
		["@markup.list"] = { fg = c.accent4 },
		["@markup.list.checked"] = { fg = c.ok },
		["@markup.list.unchecked"] = { fg = c.fg_muted },

		["@diff.plus"] = "Added",
		["@diff.minus"] = "Removed",
		["@diff.delta"] = "Changed",

		["@tag"] = "Tag",
		["@tag.builtin"] = { fg = c.keyword, italic = true },
		["@tag.attribute"] = { fg = c.property },
		["@tag.delimiter"] = "Delimiter",

		-- Language-specific refinements.
		["@constructor.lua"] = { fg = c.punctuation },
		["@keyword.luap"] = { fg = c.regex },
		["@markup.raw.markdown_inline"] = { fg = c.string, bg = c.bg_raised },
		["@markup.heading.1.delimiter.vimdoc"] = { fg = c.fg_faint },
		["@markup.heading.2.delimiter.vimdoc"] = { fg = c.fg_faint },

		-- Non-standard captures still emitted by some grammars and plugins.
		["@character.printf"] = "@string.escape",
		["@comment.hint"] = { fg = c.bg, bg = c.hint, bold = true },
		["@comment.info"] = "@comment.note",
		["@keyword.export"] = "@keyword.import",
		["@keyword.storage"] = "@keyword.modifier",
		["@markup.emphasis"] = "@markup.italic",
		["@markup.environment"] = { fg = c.keyword },
		["@markup.environment.name"] = { fg = c.type },
		["@markup.link.label.symbol"] = { fg = c.link },
		["@namespace.builtin"] = "@module.builtin",
		["@punctuation"] = { fg = c.punctuation },
		["@type.qualifier"] = "@keyword.modifier",
		["@none"] = {},
		["@conceal"] = "Conceal",
		["@spell"] = {},
		["@nospell"] = {},
		["@field"] = "@variable.member",
		["@parameter"] = "@variable.parameter",
		["@namespace"] = "@module",
		["@float"] = "@number.float",
		["@symbol"] = "@string.special.symbol",
		["@text"] = "@markup",
		["@text.literal"] = "@markup.raw",
		["@text.uri"] = "@markup.link.url",
		["@text.reference"] = "@markup.link",
		["@text.title"] = "@markup.heading",
		["@text.emphasis"] = "@markup.italic",
		["@text.strong"] = "@markup.strong",
		["@text.todo"] = "@comment.todo",
		["@text.note"] = "@comment.note",
		["@text.warning"] = "@comment.warning",
		["@text.danger"] = "@comment.error",
		["@text.diff.add"] = "@diff.plus",
		["@text.diff.delete"] = "@diff.minus",
		["@markup"] = {},
	}

	for level, accent in ipairs(c.rainbow) do
		groups["@markup.heading." .. level] = { fg = accent, bold = true }
		groups["@markup.heading." .. level .. ".marker"] = { fg = accent, bold = true }
	end

	return groups
end

return M
