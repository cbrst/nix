local M = {}

function M.setup()
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("ConfigLuaFiletype", { clear = true }),
		pattern = "lua",
		desc = "Use Lua-specific indentation",
		callback = function()
			vim.bo.shiftwidth = 2
			vim.bo.tabstop = 2
		end,
	})
end

return M
