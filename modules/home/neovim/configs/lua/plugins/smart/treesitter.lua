local M = {}

-- ┌────────────────────────────┐
-- │ On-demand parser features  │
-- └────────────────────────────┘
function M.setup()
	local treesitter = require("nvim-treesitter")

	-- This API supersedes the removed nvim-treesitter.configs module.
	treesitter.setup()

	local function attach_features(buf, language)
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end

		local has_parser = pcall(vim.treesitter.start, buf, language)
		if not has_parser then
			return
		end

		-- Reset folds in every visible buffer window after its parser attaches.
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == buf then
				vim.wo[win].foldmethod = "expr"
				vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.api.nvim_win_call(win, function()
					vim.cmd("silent! normal! zx")
				end)
			end
		end
	end

	local function enable_features(event)
		local filetype = vim.bo[event.buf].filetype
		local has_language, language = pcall(vim.treesitter.language.get_lang, filetype)
		if not has_language or not language then
			return
		end

		attach_features(event.buf, language)
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("treesitter-features", { clear = true }),
		desc = "Enable Tree-sitter features for installed parsers",
		callback = enable_features,
	})
end

return M
