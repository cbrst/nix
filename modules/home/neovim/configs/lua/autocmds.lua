--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

local editing_statuscolumn = "%s%=%{v:virtnum == 0 ? (&rnu && v:relnum > 0 ? v:relnum : v:lnum) : ''} %C "
local function set_editing_statuscolumn(buf)
	local statuscolumn = vim.bo[buf].buftype == "" and editing_statuscolumn or ""
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		vim.wo[win].statuscolumn = statuscolumn
	end
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "TermOpen" }, {
	desc = "Use the custom status column only in editing buffers",
	group = vim.api.nvim_create_augroup("editing-statuscolumn", { clear = true }),
	callback = function(event)
		set_editing_statuscolumn(event.buf)
	end,
})

set_editing_statuscolumn(vim.api.nvim_get_current_buf())

-- Terminal buffers (e.g. Claude Code's TUI) move the cursor on nearly every
-- line of output. mini.animate's cursor-jump animation turns that into a
-- continuous stream of timer-driven redraws, which makes typing in the
-- terminal feel laggy. cursorline repaints add to that, so skip both there.
vim.api.nvim_create_autocmd("TermOpen", {
	desc = "Disable cursor animation and cursorline in terminal buffers",
	group = vim.api.nvim_create_augroup("terminal-performance", { clear = true }),
	callback = function()
		vim.b.minianimate_disable = true
		vim.wo.cursorline = false
	end,
})

-- Overwrite highlight FlnStatusBg on BufEnter
-- Somehow the gui=bold gets removed sometimes
-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	desc = "Make sure FlnStatusBg is bold",
-- 	group = vim.api.nvim_create_augroup("kickstart-highlight-flnstatusbg", { clear = true }),
-- 	callback = function()
-- 		vim.cmd("hi FlnStatusBg cterm=bold gui=bold")
-- 	end,
-- })
