local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("ConfigMarkdownFiletype", { clear = true }),
		pattern = "markdown",
		desc = "Configure Markdown editing",
		callback = function()
			-- Rendered Markdown markers stay hidden while replacement characters remain visible.
			vim.wo.conceallevel = 2
			vim.wo.wrap = true
			vim.wo.linebreak = true
			vim.wo.breakindent = true
			vim.bo.textwidth = 0
			vim.bo.wrapmargin = 0
		end,
	})
end

return M
