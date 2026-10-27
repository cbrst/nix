local M = {}

-- ╭───────────────────────────╮
-- │ Terminal split placement  │
-- ╰───────────────────────────╯

-- Columns the code must keep beside a right-side terminal, which takes the
-- `split` style's 40% of the editor width.
local min_code_columns = 100
local right_width = 0.4

-- Right when the tab has a single column of windows and the code keeps
-- `min_code_columns` beside the terminal, otherwise bottom. Fixed-width
-- sidebars such as Neo-tree and Outline only reduce the available width;
-- terminals (Claude Code included) count as a column of their own.
function M.terminal_position()
	local columns, sidebar_width = {}, 0
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_config(win).relative == "" then
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.wo[win].winfixwidth and vim.bo[buf].buftype ~= "terminal" then
				-- Sidebar plus its separator column.
				sidebar_width = sidebar_width + vim.api.nvim_win_get_width(win) + 1
			else
				columns[vim.api.nvim_win_get_position(win)[2]] = true
			end
		end
	end
	if vim.tbl_count(columns) > 1 then
		return "bottom"
	end
	local code = vim.o.columns - sidebar_width - math.floor(vim.o.columns * right_width)
	return code >= min_code_columns and "right" or "bottom"
end

-- Runs a Snacks terminal action ("toggle", "open" or "focus") with the split
-- placed by `terminal_position()`. A hidden terminal is moved before it is
-- shown again, so it follows the layout at that moment.
function M.terminal(action, cmd, opts)
	local snacks = require("snacks")
	local position = M.terminal_position()
	opts = vim.tbl_deep_extend("force", opts or {}, { win = { position = position } })
	if action ~= "open" then
		local term = snacks.terminal.get(cmd, vim.tbl_extend("force", opts, { create = false }))
		if term and not term:valid() then
			term.opts.position = position
		end
	end
	return snacks.terminal[action](cmd, opts)
end

function M.setup()
	local dashboard = require("init6.plugins.ui.dashboard")
	dashboard.setup()

	-- Sending picker items to Claude needs claudecode.nvim, which is only
	-- installed with the `ai` feature.
	local ai_keys, ai_actions = {}, {}
	if require("init6.config.features").ai then
		ai_keys["<a-o>"] = { "claudecode_send", mode = { "n", "i" } }
		ai_actions.claudecode_send = function(picker)
			local claudecode = require("claudecode")
			local path = require("snacks").picker.util.path

			for _, item in ipairs(picker:selected({ fallback = true })) do
				if item.file then
					local start_line = item.pos and item.pos[1] and item.pos[1] - 1 or nil
					local end_line = item.end_pos and item.end_pos[1] and item.end_pos[1] - 1 or start_line
					claudecode.send_at_mention(path(item), start_line, end_line, "SnacksPicker")
				end
			end
		end
	end

	require("snacks").setup({
		dashboard = dashboard.opts(),
		dim = {},
		-- Keep the general shell-terminal workflow available independently of AI chat.
		input = { enabled = true },
		picker = {
			enabled = true,
			win = {
				input = {
					keys = ai_keys,
				},
			},
			actions = ai_actions,
		},
		terminal = { enabled = true },
	})
	-- Dimming has no `enabled` option; it only starts through enable().
	require("snacks").dim.enable()
	require("snacks").toggle.dim():map("<leader>td")
	-- Normal mode only: a "t" (terminal-mode) binding here would eat the
	-- literal "<space>t"/"<space>f" keystrokes typed into any terminal buffer
	-- (e.g. Claude Code's prompt), firing this instead of sending them through.
	vim.keymap.set("n", "<leader>ot", function()
		M.terminal("toggle")
	end, { desc = "Toggle terminal popup" })
	vim.keymap.set("n", "<leader>oT", function()
		M.terminal("open")
	end, { desc = "Open terminal here" })
	vim.keymap.set("n", "<leader>of", function()
		M.terminal("focus")
	end, { desc = "Focus terminal" })
end

return M
