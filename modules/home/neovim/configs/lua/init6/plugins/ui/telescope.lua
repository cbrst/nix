local M = {}

-- Ripgrep honours .gitignore even without a .git directory (non-colocated jj
-- repos), shows dotfiles, and never descends into VCS metadata.
local rg_filters = { "--hidden", "--no-require-git", "--glob", "!**/.git/*", "--glob", "!**/.jj/*" }
local include_ignored_key = "<M-i>"
local lga_mappings = {}

-- Reopens the picker with ignored files toggled, keeping the typed prompt.
local function ignore_toggle(open, opts, include_ignored)
	return function(prompt_bufnr)
		local prompt = require("telescope.actions.state").get_current_line()
		require("telescope.actions").close(prompt_bufnr)
		open(vim.tbl_extend("force", opts, { default_text = prompt }), not include_ignored)
	end
end

local function title(base, include_ignored)
	return include_ignored and base .. " (+ignored)" or base
end

-- Find files, excluding ignored files unless <M-i> toggles them in.
function M.find_files(opts, include_ignored)
	opts = opts or {}
	local cmd = vim.list_extend({ "rg", "--files", "--color", "never" }, rg_filters)
	if include_ignored then
		table.insert(cmd, "--no-ignore")
	end
	require("telescope.builtin").find_files(vim.tbl_extend("force", opts, {
		find_command = cmd,
		prompt_title = title("Find Files", include_ignored),
		attach_mappings = function(_, map)
			map("i", include_ignored_key, ignore_toggle(M.find_files, opts, include_ignored))
			return true
		end,
	}))
end

-- Live grep that accepts ripgrep flags when the live_grep_args extension is
-- loaded, excluding ignored files unless <M-i> toggles them in.
function M.live_grep(opts, include_ignored)
	opts = opts or {}
	local toggle = ignore_toggle(M.live_grep, opts, include_ignored)
	local picker_opts = vim.tbl_extend("force", opts, {
		additional_args = include_ignored and { "--no-ignore" } or nil,
	})
	-- Telescope's extensions table errors on access when the extension is absent.
	local ok, lga = pcall(function()
		return require("telescope").extensions.live_grep_args
	end)
	if ok and lga then
		-- Per-call mappings replace the extension's configured ones, so merge them.
		local mappings = vim.deepcopy(lga_mappings)
		mappings.i = mappings.i or {}
		mappings.i[include_ignored_key] = toggle
		lga.live_grep_args(vim.tbl_extend("force", picker_opts, {
			mappings = mappings,
			prompt_title = title("Live Grep (Args)", include_ignored),
		}))
	else
		require("telescope.builtin").live_grep(vim.tbl_extend("force", picker_opts, {
			prompt_title = title("Live Grep", include_ignored),
			attach_mappings = function(_, map)
				map("i", "<C-Space>", require("telescope.actions").to_fuzzy_refine)
				map("i", include_ignored_key, toggle)
				return true
			end,
		}))
	end
end

-- ┌────────────────────────────┐
-- │ Telescope search workflows │
-- └────────────────────────────┘
function M.setup()
	-- Live grep args accepts ripgrep flags in the prompt, e.g. `"pattern" -t lua` or `"pattern" -g *.nix`.
	local lga_ok, lga_actions = pcall(require, "telescope-live-grep-args.actions")
	if lga_ok then
		lga_mappings = {
			i = {
				["<C-k>"] = lga_actions.quote_prompt(),
				["<C-t>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
			},
		}
	end
	require("telescope").setup({
		defaults = require("telescope.themes").get_ivy({
			vimgrep_arguments = vim.list_extend({
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
			}, rg_filters),
		}),
		extensions = {
			["ui-select"] = require("telescope.themes").get_dropdown(),
			live_grep_args = lga_ok and { auto_quoting = true, mappings = lga_mappings } or nil,
		},
	})

	-- Nix builds and installs these extensions; keep startup resilient if any is absent.
	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")
	pcall(require("telescope").load_extension, "live_grep_args")

	local builtin = require("telescope.builtin")
	local find_files, live_grep = M.find_files, M.live_grep
	local function project_root()
		local root = require("init6.plugins.ui.vcs").context(0)
		return root or vim.fn.getcwd()
	end

	vim.keymap.set("n", "<leader>hh", builtin.help_tags, { desc = "Search help" })
	vim.keymap.set("n", "<leader>hbb", builtin.keymaps, { desc = "Search keybindings" })
	vim.keymap.set("n", "<leader>.", function()
		find_files()
	end, { desc = "Find file" })
	vim.keymap.set("n", "<leader>ff", function()
		find_files()
	end, { desc = "Find file" })
	vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
	vim.keymap.set("n", "<leader>,", builtin.buffers, { desc = "Switch buffer" })
	vim.keymap.set("n", "<leader>bb", builtin.buffers, { desc = "Switch buffer" })
	vim.keymap.set("n", "<leader><leader>", function()
		find_files({ cwd = project_root() })
	end, { desc = "Find file in project" })
	vim.keymap.set("n", "<leader>/", function()
		live_grep({ cwd = project_root() })
	end, { desc = "Search project (rg flags: -t lua, -g *.nix)" })
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
		-- The standalone flake package bundles the configuration outside stdpath.
		find_files({ cwd = vim.g.init6_config_dir or vim.fn.stdpath("config") })
	end, { desc = "Find file in Neovim config" })
end

return M
