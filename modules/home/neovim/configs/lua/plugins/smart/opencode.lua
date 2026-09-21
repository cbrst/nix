local M = {}

local opencode_cmd = "opencode --port"
local terminal_opts = {
	win = {
		position = "right",
		enter = false,
	},
}

function M.toggle()
	require("snacks").terminal.toggle(opencode_cmd, terminal_opts)
end

function M.setup()
	---@type opencode.Opts
	vim.g.opencode_opts = {
		server = {
			start = function()
				require("snacks").terminal.open(opencode_cmd, terminal_opts)
			end,
		},
	}

	local opencode = require("opencode")

	vim.keymap.set({ "n", "t" }, "<leader>oll", M.toggle, { desc = "Toggle OpenCode" })
	vim.keymap.set({ "n", "x" }, "<leader>ola", function()
		opencode.ask("@this: ")
	end, { desc = "Ask OpenCode" })
	vim.keymap.set({ "n", "x" }, "<leader>ols", opencode.select, { desc = "Select OpenCode action" })
	vim.keymap.set("n", "<leader>oln", function()
		opencode.command("session.new")
	end, { desc = "New OpenCode session" })
	vim.keymap.set("n", "<leader>olc", function()
		opencode.command("agent.cycle")
	end, { desc = "Cycle OpenCode agent" })
	vim.keymap.set({ "n", "x" }, "<leader>olr", function()
		opencode.ask("Improve @this: ")
	end, { desc = "Rewrite with OpenCode" })
	vim.keymap.set("n", "<leader>olR", function()
		opencode.prompt(
			"Review the current changes for bugs, regressions, and missing tests. Report findings first, ordered by severity, with file and line references."
		)
	end, { desc = "Review code with OpenCode" })

	vim.api.nvim_create_autocmd("User", {
		group = vim.api.nvim_create_augroup("OpencodeIntegrations", { clear = true }),
		pattern = "OpencodeEvent:*",
		callback = function(args)
			vim.schedule(vim.cmd.redrawstatus)

			local event = args.data.event
			if event.type == "tui.command.execute" and event.properties.command == "prompt.submit" then
				local terminal = require("snacks").terminal.get(opencode_cmd, { create = false })
				if terminal then
					terminal:show()
				end
			end
		end,
	})
end

return M
