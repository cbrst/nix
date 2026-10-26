local M = {}

-- ┌────────────────────────────┐
-- │ Commands and mappings      │
-- └────────────────────────────┘
function M.setup()
	-- Start a rename after "Extract to function/constant" refactors.
	require("vtsls").config({ refactor_auto_rename = true })

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("init6-vtsls", { clear = true }),
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if not client or client.name ~= "vtsls" then
				return
			end

			local commands = require("vtsls").commands
			local function map(keys, command, description)
				vim.keymap.set("n", keys, function()
					commands[command](event.buf)
				end, { buffer = event.buf, desc = "TypeScript: " .. description })
			end

			-- The everyday source actions sit directly under Code.
			map("<leader>co", "organize_imports", "Organize imports")
			map("<leader>cm", "add_missing_imports", "Add missing imports")
			map("<leader>cu", "remove_unused", "Remove unused declarations")
			map("<leader>cF", "fix_all", "Fix all")
			map("<leader>cR", "rename_file", "Rename file and update imports")
			map("gS", "goto_source_definition", "[G]oto [S]ource definition")

			-- Project and server commands.
			require("which-key").add({ { "<leader>cT", group = "TypeScript", buffer = event.buf } })
			map("<leader>cTc", "goto_project_config", "Open tsconfig/jsconfig")
			map("<leader>cTf", "file_references", "File references")
			map("<leader>cTs", "sort_imports", "Sort imports")
			map("<leader>cTu", "remove_unused_imports", "Remove unused imports")
			map("<leader>cTv", "select_ts_version", "Select TypeScript version")
			map("<leader>cTr", "restart_tsserver", "Restart tsserver")
			map("<leader>cTR", "reload_projects", "Reload projects")
			map("<leader>cTl", "open_tsserver_log", "Open tsserver log")
		end,
	})
end

return M
