local M = {}

-- ┌───────────────────────────────┐
-- │ Shared status and WinBar hues │
-- └───────────────────────────────┘
function M.get()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	local visual = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
	local statusline = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
	local statusline_nc = vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false })
	local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
	local normal_float = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
	return {
		bar = statusline.bg or normal.bg,
		inactive = statusline_nc.bg or normal_float.bg or normal.bg,
		fg = statusline.fg or normal.fg,
		muted = comment.fg or statusline_nc.fg or normal.fg,
		tab = normal.bg,
		editor = normal.bg,
		context = visual.fg or visual.bg or normal.fg,
		command = normal_float.bg or normal.bg,
	}
end

function M.apply()
	local colors = M.get()
	local directory = vim.api.nvim_get_hl(0, { name = "Directory", link = false })

	-- Heirline owns StatusLine; Dropbar inherits the editor-colored WinBar surface.
	vim.api.nvim_set_hl(0, "StatusLine", { bg = colors.bar, fg = colors.fg })
	vim.api.nvim_set_hl(0, "StatusLineNC", { bg = colors.inactive, fg = colors.muted })
	vim.api.nvim_set_hl(0, "WinBar", { bg = colors.editor, fg = colors.fg })
	vim.api.nvim_set_hl(0, "WinBarNC", { bg = colors.editor, fg = colors.muted })

	-- Dropbar marks the active path item with Visual by default, including a contrasting background.
	-- Retain the foreground cue while keeping current folders flush with the editor background.
	vim.api.nvim_set_hl(0, "DropBarCurrentContext", { bg = colors.editor, fg = colors.context })
	vim.api.nvim_set_hl(0, "DropBarCurrentContextIcon", { bg = colors.editor, fg = colors.context })
	vim.api.nvim_set_hl(0, "DropBarCurrentContextName", { bg = colors.editor, fg = colors.context })
	vim.api.nvim_set_hl(0, "DropBarHover", { bg = colors.editor, fg = colors.context })
	-- Directory's theme background leaks through Dropbar's active folder icons.
	vim.api.nvim_set_hl(0, "DropBarIconKindFolder", { bg = colors.editor, fg = directory.fg })

	-- Keep command entry distinct with subdued text and without changing editor surfaces.
	vim.api.nvim_set_hl(0, "MsgArea", { bg = colors.command, fg = colors.muted })
	vim.api.nvim_set_hl(0, "MsgSeparator", { bg = colors.command, fg = colors.command })

	-- Keep neo-tree colors clean
	vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", { link = "NeoTreeFileName" })
end

return M
