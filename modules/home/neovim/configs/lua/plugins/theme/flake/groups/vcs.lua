local blend = require("plugins.theme.flake.color").blend

local M = {}

-- ┌──────────────────────────────────────┐
-- │ Neogit and NeoJJ                     │
-- └──────────────────────────────────────┘
-- Both plugins otherwise derive "green" from String, "yellow" from PreProc and
-- so on. Defining the colour-bearing groups here keeps status buffers on the
-- palette's version-control colours; their remaining groups link to these.
local function groups_for(prefix, c)
	local graph = {
		Red = c.removed,
		Orange = c.accent4,
		Yellow = c.warning,
		Green = c.added,
		Cyan = c.accent3,
		Blue = c.link,
		Purple = c.accent2,
		Gray = c.fg_faint,
		White = c.fg,
	}
	local change = {
		Modified = c.changed,
		Added = c.added,
		NewFile = c.added,
		Deleted = c.removed,
		Renamed = c.accent2,
		Updated = c.accent4,
		Copied = c.accent3,
		Unmerged = c.warning,
	}
	local header = { fg = c.bg, bg = c.fg_faint, bold = true }
	local header_active = { fg = c.bg, bg = c.accent2, bold = true }

	local groups = {
		GraphAuthor = { fg = c.accent4 },
		HunkHeader = header,
		HunkHeaderHighlight = header_active,
		HunkHeaderCursor = header_active,
		HunkMergeHeader = header,
		HunkMergeHeaderHighlight = { fg = c.bg, bg = c.accent3, bold = true },
		HunkMergeHeaderCursor = { fg = c.bg, bg = c.accent3, bold = true },
		DiffContext = { bg = c.bg_raised },
		DiffContextHighlight = { bg = c.bg_strong },
		DiffContextCursor = { bg = c.bg_raised },
		DiffAdditions = { fg = c.added },
		DiffDeletions = { fg = c.removed },
		DiffAdd = { fg = c.added, bg = c.diff.add },
		DiffAddHighlight = { fg = c.added, bg = c.diff.add },
		DiffAddCursor = { fg = c.added, bg = c.bg_raised },
		DiffAddInline = { fg = c.fg, bg = c.diff.add_inline, bold = true },
		DiffDelete = { fg = c.removed, bg = c.diff.delete },
		DiffDeleteHighlight = { fg = c.removed, bg = c.diff.delete },
		DiffDeleteCursor = { fg = c.removed, bg = c.bg_raised },
		DiffDeleteInline = { fg = c.fg, bg = c.diff.delete_inline, bold = true },
		DiffHeader = { fg = c.link, bg = c.bg_strong, bold = true },
		DiffHeaderHighlight = { fg = c.accent4, bg = c.bg_strong, bold = true },
		FilePath = { fg = c.link, italic = true },
		CommitViewHeader = { fg = c.bg, bg = c.accent3, bold = true },
		Branch = { fg = c.link, bold = true },
		BranchHead = { fg = c.link, bold = true, underline = true },
		Remote = { fg = c.added, bold = true },
		SectionHeader = { fg = c.accent2, bold = true },
		PopupSectionTitle = { fg = c.func, bold = true },
		PopupBranchName = { fg = c.link },
		PopupSwitchKey = { fg = c.accent2 },
		PopupOptionKey = { fg = c.accent2 },
		PopupConfigKey = { fg = c.accent2 },
		PopupActionKey = { fg = c.accent2 },
		PopupSwitchEnabled = { fg = c.accent4 },
		PopupOptionEnabled = { fg = c.accent4 },
		PopupConfigEnabled = { fg = c.accent4 },
		UnmergedInto = { fg = c.accent2, bold = true },
		UnpushedTo = { fg = c.accent2, bold = true },
		UnpulledFrom = { fg = c.accent2, bold = true },
		TagName = { fg = c.warning },
		TagDistance = { fg = c.accent3 },
		FloatHeader = { bg = c.bg_raised, bold = true },
		FloatHeaderHighlight = { fg = c.accent3, bg = c.bg_strong, bold = true },
		ActiveItem = { fg = c.bg, bg = c.accent4, bold = true },
		-- NeoJJ-only states.
		ForgePR = { fg = c.accent2, bold = true },
		ObjectId = { fg = c.fg_faint },
		ChangeId = { fg = blend(c.accent2, c.fg_faint, 0.6) },
		ChangeIdPrefix = { fg = c.accent2, bold = true },
		ChangeIdRest = { fg = c.fg_faint },
		Conflict = { fg = c.warning, bold = true },
		Divergent = { fg = c.error, bold = true },
		Immutable = { fg = c.fg_faint, italic = true },
		WorkingCopy = { fg = c.added, bold = true },
	}

	for name, fg in pairs(graph) do
		groups["Graph" .. name] = { fg = fg }
		groups["GraphBold" .. name] = { fg = fg, bold = true }
	end
	for name, fg in pairs(change) do
		groups["Change" .. name] = { fg = fg, bold = true, italic = true }
	end

	local prefixed = {}
	for name, spec in pairs(groups) do
		prefixed[prefix .. name] = spec
	end
	return prefixed
end

function M.get(c)
	return vim.tbl_extend("force", groups_for("Neogit", c), groups_for("Neojj", c))
end

return M
