local M = {}

function M.setup()
	require("gitsigns").setup({
		signs = {
			add = { text = "▏ " },
			change = { text = "▏ " },
			delete = { text = "▏ " },
			topdelete = { text = "▏ " },
			changedelete = { text = "▏ " },
			untracked = { text = "▏ " },
		},
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")
			local function map(mode, keys, action, options)
				options = options or {}
				options.buffer = bufnr
				vim.keymap.set(mode, keys, action, options)
			end

			-- Preserve native diff navigation while using Gitsigns in regular buffers.
			map("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end, { desc = "Jump to next git [c]hange" })
			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, { desc = "Jump to previous git [c]hange" })
			map("v", "<leader>gs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Stage hunk" })
			map("v", "<leader>gr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "Revert hunk" })
			map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
			map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Revert hunk" })
			map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage buffer" })
			map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
			map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Revert buffer" })
			map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
			map("n", "<leader>gb", gitsigns.blame_line, { desc = "Blame line" })
			map("n", "<leader>gd", gitsigns.diffthis, { desc = "Diff against index" })
			map("n", "<leader>gD", function()
				gitsigns.diffthis("@")
			end, { desc = "Diff against last commit" })
			map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle Git blame" })
			map("n", "<leader>tD", gitsigns.toggle_deleted, { desc = "Toggle Git deleted lines" })
		end,
	})
end

return M
