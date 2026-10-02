local M = {}

local review_prompt =
	"Review the current changes for bugs, regressions, and missing tests. Report findings first, ordered by severity, with file and line references."

local function capture_context()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		return nil
	end

	local mode = vim.fn.mode()
	local start_line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local end_line = start_line

	if mode == "v" or mode == "V" or mode == "\22" then
		start_line = vim.fn.line("v") - 1
		end_line = vim.fn.line(".") - 1
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
	end

	return { path = path, start_line = start_line, end_line = end_line }
end

local function send_prompt(prompt, context)
	if context then
		require("claudecode").send_at_mention(context.path, context.start_line, context.end_line, "NeovimPrompt")
	end

	local terminal = require("claudecode.terminal")
	terminal.open()
	vim.defer_fn(function()
		terminal.send_to_terminal(prompt)
	end, context and 150 or 0)
end

local function prompt_for_context(context, label, prefix)
	vim.ui.input({ prompt = label }, function(input)
		if input == nil or input == "" then
			return
		end

		send_prompt(prefix .. input, context)
	end)
end

function M.toggle()
	require("claudecode.terminal").simple_toggle()
end

function M.ask(context)
	prompt_for_context(context or capture_context(), "Ask Claude: ", "")
end

function M.improve(context)
	prompt_for_context(context or capture_context(), "Improve current context: ", "Improve the current code: ")
end

function M.new_session()
	send_prompt("/clear")
end

function M.select_model()
	send_prompt("/model")
end

function M.review()
	send_prompt(review_prompt)
end

function M.select()
	local context = capture_context()
	local actions = {
		{
			label = "Ask about current context",
			run = function()
				M.ask(context)
			end,
		},
		{
			label = "Improve current context",
			run = function()
				M.improve(context)
			end,
		},
		{ label = "Review current changes", run = M.review },
		{ label = "Start new session", run = M.new_session },
		{ label = "Select model", run = M.select_model },
		{ label = "Toggle Claude Code", run = M.toggle },
	}

	vim.ui.select(actions, {
		prompt = "Claude Code action",
		format_item = function(action)
			return action.label
		end,
	}, function(action)
		if action then
			action.run()
		end
	end)
end

function M.setup()
	require("claudecode").setup({
		terminal = {
			provider = "snacks",
			split_side = "right",
			auto_insert = true,
			snacks_win_opts = {
				position = "right",
				enter = true,
				wo = { winbar = "" },
			},
		},
	})

	-- Terminal-mode ("t") keymaps intercept keystrokes before they reach the
	-- running program, so they must not share a prefix with anything you'd
	-- type into Claude Code's prompt. Only bind these in normal mode; use
	-- <Esc><Esc> (see keymap.lua) to drop to terminal-normal mode first.
	vim.keymap.set("n", "<leader>oll", M.toggle, { desc = "Toggle Claude Code" })
	vim.keymap.set({ "n", "x" }, "<leader>ola", function()
		M.ask()
	end, { desc = "Ask Claude Code" })
	vim.keymap.set({ "n", "x" }, "<leader>ols", M.select, { desc = "Select Claude Code action" })
	vim.keymap.set("n", "<leader>oln", M.new_session, { desc = "New Claude Code session" })
	vim.keymap.set("n", "<leader>olc", M.select_model, { desc = "Select Claude Code model" })
	vim.keymap.set({ "n", "x" }, "<leader>olr", function()
		M.improve()
	end, { desc = "Rewrite with Claude Code" })
	vim.keymap.set("n", "<leader>olR", M.review, { desc = "Review code with Claude Code" })

	vim.api.nvim_create_autocmd({ "TermOpen", "TermClose" }, {
		group = vim.api.nvim_create_augroup("ClaudeCodeIntegrations", { clear = true }),
		callback = function()
			vim.cmd.redrawstatus()
		end,
	})
end

return M
