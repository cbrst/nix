local M = {}
local icons = require("utils.icons")

function M.setup()
	local dap = require("dap")
	local dapui = require("dapui")

	local signs = {
		DapBreakpoint = { text = icons.debugger.breakpoint, texthl = "DiagnosticError" },
		DapBreakpointCondition = { text = icons.debugger.breakpoint, texthl = "DiagnosticWarn" },
		DapBreakpointRejected = { text = icons.debugger.rejected, texthl = "DiagnosticError" },
		DapLogPoint = { text = icons.debugger.logpoint, texthl = "DiagnosticInfo" },
		DapStopped = { text = icons.debugger.stopped, texthl = "DiagnosticWarn", numhl = "DiagnosticWarn" },
	}

	for name, sign in pairs(signs) do
		vim.fn.sign_define(name, sign)
	end

	dapui.setup({})
	require("nvim-dap-virtual-text").setup({})

	dap.listeners.after.event_initialized["dapui"] = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated["dapui"] = function()
		dapui.close()
	end
	dap.listeners.before.event_exited["dapui"] = function()
		dapui.close()
	end

	dap.adapters.debugpy = {
		type = "executable",
		command = vim.fn.exepath("debugpy-adapter"),
	}
	dap.configurations.python = {
		{
			type = "debugpy",
			request = "launch",
			name = "Debug current file",
			program = "${file}",
			cwd = "${workspaceFolder}",
			pythonPath = function()
				for _, path in ipairs({ ".venv/bin/python", "venv/bin/python" }) do
					local python = vim.fs.joinpath(vim.fn.getcwd(), path)
					if vim.fn.executable(python) == 1 then
						return python
					end
				end
				return vim.fn.exepath("python3")
			end,
		},
	}

	dap.adapters["pwa-node"] = {
		type = "server",
		host = "127.0.0.1",
		port = "${port}",
		executable = {
			command = vim.fn.exepath("js-debug"),
			args = { "${port}" },
		},
	}
	local js_configurations = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Debug current file",
			program = "${file}",
			cwd = "${workspaceFolder}",
			runtimeExecutable = "node",
			console = "integratedTerminal",
			sourceMaps = true,
			skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
		},
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach to Node process",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
			sourceMaps = true,
		},
	}
	for _, filetype in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
		dap.configurations[filetype] = js_configurations
	end

	local function real_executable(name)
		local path = vim.fn.exepath(name)
		return vim.uv.fs_realpath(path) or path
	end

	local bashdb = real_executable("bashdb")
	dap.adapters.bashdb = {
		type = "executable",
		command = vim.fn.exepath("bash-debug-adapter"),
	}
	local shell_configurations = {
		{
			type = "bashdb",
			request = "launch",
			name = "Debug current file with Bash",
			program = "${file}",
			cwd = "${workspaceFolder}",
			pathBash = real_executable("bash"),
			pathBashdb = bashdb,
			pathBashdbLib = vim.fs.joinpath(vim.fs.dirname(vim.fs.dirname(bashdb)), "share", "bashdb"),
			pathCat = real_executable("cat"),
			pathMkfifo = real_executable("mkfifo"),
			pathPkill = real_executable("pkill"),
			terminalKind = "integrated",
			showDebugOutput = false,
			trace = false,
		},
	}
	dap.configurations.sh = shell_configurations
	-- There is no native Zsh DAP adapter; this profile only works for Bash-compatible scripts.
	dap.configurations.zsh = shell_configurations

	dap.adapters["lua-local"] = {
		type = "executable",
		command = vim.fn.exepath("local-lua-debug-adapter"),
	}
	dap.adapters.nlua = function(callback, config)
		callback({
			type = "server",
			host = config.host or "127.0.0.1",
			port = config.port or 8086,
		})
	end
	dap.configurations.lua = {
		{
			type = "lua-local",
			request = "launch",
			name = "Debug current Lua file",
			cwd = "${workspaceFolder}",
			program = {
				lua = real_executable("lua"),
				file = "${file}",
			},
		},
		{
			type = "nlua",
			request = "attach",
			name = "Attach to Neovim",
		},
	}

	vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: start/continue" })
	vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: step over" })
	vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: step into" })
	vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: step out" })
	vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
	vim.keymap.set("n", "<leader>dB", function()
		dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
	end, { desc = "Set conditional breakpoint" })
	vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start/continue debugging" })
	vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run last debug session" })
	vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle debug REPL" })
	vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle debug UI" })
	vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Terminate debug session" })
	vim.keymap.set({ "n", "x" }, "<leader>de", dapui.eval, { desc = "Evaluate expression" })
	vim.keymap.set("n", "<leader>dL", function()
		require("osv").launch({ port = 8086 })
	end, { desc = "Launch Neovim Lua debug server" })
end

return M
