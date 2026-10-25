local color = require("plugins.theme.flake.color")
local blend = color.blend

local M = {}

-- ┌──────────────────────────────────────┐
-- │ Semantic roles from the Nix palette  │
-- └──────────────────────────────────────┘
-- `p` is one variant from lib/themes.nix; `terminal` is its derived ANSI set.
-- Colours the palette has no slot for are blended from neighbouring slots so
-- every family gets the same structure.
function M.build(p, terminal)
	local bg, fg = p.background, p.foreground
	local c = {
		none = "NONE",
		terminal = terminal.palette,

		-- Surfaces, from the outermost frame inward to the selection.
		bg = bg,
		bg_deep = p.shade0,
		bg_raised = p.shade2,
		bg_line = p.hover,
		bg_strong = p.shade3,
		bg_heavy = p.shade4,
		bg_visual = p.selected,

		-- Text tiers.
		fg = fg,
		fg_muted = p.muted,
		fg_faint = p.faint,
		gutter = p.faint,
		comment = p.muted,
		border = p.border,

		-- Accents.
		accent = p.accent,
		accent_fg = p.accentForeground,
		accent2 = p.accent2,
		accent3 = p.accent3,
		accent4 = p.accent4,
		accent5 = p.accent5,
		link = p.link,

		-- Status.
		error = p.error,
		warning = p.warning,
		info = p.info,
		hint = p.accent3,
		ok = p.success,

		-- Syntax.
		keyword = p.syntaxKeyword,
		func = p.syntaxFunction,
		string = p.syntaxString,
		number = p.syntaxNumber,
		type = p.syntaxType,
		operator = p.syntaxOperator,
		punctuation = p.syntaxPunctuation,
		constant = p.accent4,
		special = p.accent4,
		builtin = p.syntaxKeyword,
		attribute = p.accent5,

		-- Version control.
		added = p.added,
		removed = p.removed,
		changed = p.changed,
	}

	-- The command line sits below the editor: the darker neighbouring shade in
	-- either variant (shade0 is darkest in dark palettes, lightest in light ones).
	c.bg_command = color.darker(p.shade0, p.shade2)

	-- Derived text tones for groups the palette has no slot for.
	c.guide = blend(c.border, bg, 0.5)
	c.whitespace = blend(c.border, bg, 0.35)
	c.parameter = blend(c.accent4, fg, 0.4)
	c.property = blend(c.accent3, fg, 0.45)
	c.module = blend(c.type, fg, 0.7)
	c.regex = blend(c.string, c.accent4, 0.6)
	c.escape = c.accent4
	c.border_highlight = blend(c.accent, bg, 0.6)

	-- Washes behind text: search, matches, references and diagnostics.
	c.bg_search = blend(c.warning, bg, 0.3)
	c.bg_search_current = blend(c.accent4, bg, 0.5)
	c.bg_match = blend(c.accent3, bg, 0.25)
	c.bg_reference = blend(c.link, bg, 0.18)
	c.bg_error = blend(c.error, bg, 0.12)
	c.bg_warning = blend(c.warning, bg, 0.12)
	c.bg_info = blend(c.info, bg, 0.12)
	c.bg_hint = blend(c.hint, bg, 0.12)
	c.bg_ok = blend(c.ok, bg, 0.12)
	c.bg_accent = blend(c.accent, bg, 0.15)

	-- Diff surfaces come straight from the palette; inline highlights add contrast.
	c.diff = {
		add = p.diffAddedBg,
		delete = p.diffRemovedBg,
		change = p.diffContextBg,
		text = blend(c.changed, bg, 0.3),
		add_inline = blend(p.diffHighlightAdded, bg, 0.35),
		delete_inline = blend(p.diffHighlightRemoved, bg, 0.35),
	}

	-- Ordered accents for headings, rainbow guides and graph lanes.
	c.rainbow = { c.accent, c.accent4, c.accent5, c.accent3, c.link, c.accent2 }

	return c
end

return M
