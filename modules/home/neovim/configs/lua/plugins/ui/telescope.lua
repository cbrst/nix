local M = {}

-- ┌────────────────────────────┐
-- │ Telescope search workflows │
-- └────────────────────────────┘
function M.setup()
	require("telescope").setup({
		defaults = require("telescope.themes").get_ivy(),
		extensions = {
			["ui-select"] = require("telescope.themes").get_dropdown(),
		},
	})

	-- Nix builds and installs both extensions; keep startup resilient if either is absent.
	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")

	local builtin = require("telescope.builtin")
	local function project_root()
		return vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
	end

	vim.keymap.set("n", "<leader>hh", builtin.help_tags, { desc = "Search help" })
	vim.keymap.set("n", "<leader>hbb", builtin.keymaps, { desc = "Search keybindings" })
	vim.keymap.set("n", "<leader>.", builtin.find_files, { desc = "Find file" })
	vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find file" })
	vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
	vim.keymap.set("n", "<leader>,", builtin.buffers, { desc = "Switch buffer" })
	vim.keymap.set("n", "<leader>bb", builtin.buffers, { desc = "Switch buffer" })
	vim.keymap.set("n", "<leader><leader>", function()
		builtin.find_files({ cwd = project_root() })
	end, { desc = "Find file in project" })
	vim.keymap.set("n", "<leader>/", function()
		builtin.live_grep({ cwd = project_root() })
	end, { desc = "Search project" })
	vim.keymap.set("n", "<leader>*", function()
		builtin.grep_string({ cwd = project_root() })
	end, { desc = "Search project for word" })
	vim.keymap.set("n", "<leader>'", builtin.resume, { desc = "Resume last search" })
	vim.keymap.set("n", "<leader>st", builtin.builtin, { desc = "Select Telescope picker" })
	vim.keymap.set("n", "<leader>cX", builtin.diagnostics, { desc = "Search diagnostics" })

	local function search_buffer()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end
	vim.keymap.set("n", "<leader>sb", search_buffer, { desc = "Search buffer" })
	vim.keymap.set("n", "<leader>ss", search_buffer, { desc = "Search buffer" })
	vim.keymap.set("n", "<leader>sB", function()
		builtin.live_grep({
			grep_open_files = true,
			prompt_title = "Live Grep in Open Files",
		})
	end, { desc = "Search open buffers" })
	vim.keymap.set("n", "<leader>fp", function()
		builtin.find_files({ cwd = vim.fn.stdpath("config") })
	end, { desc = "Find file in Neovim config" })
end

return M
