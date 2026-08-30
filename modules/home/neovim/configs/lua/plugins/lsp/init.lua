local M = {}
local servers = require("config.lsp_servers")
local icons = require("utils.icons")

-- ┌────────────────────────────┐
-- │ Language-server stack      │
-- └────────────────────────────┘
function M.setup()
	-- Configure diagnostic signs
	vim.diagnostic.config({
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
				[vim.diagnostic.severity.WARN] = icons.diagnostics.warning,
				[vim.diagnostic.severity.INFO] = icons.diagnostics.info,
				[vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
			},
		},
	})

	-- LazyDev must load before Blink resolves its Lua completion source.
	require("lazydev").setup({
		library = {
			{ path = "luvit-meta/library", words = { "vim%.uv" } },
		},
	})
	require("fidget").setup({})
	require("typescript-tools").setup({
		settings = {
			jsx_close_tag = {
				enable = true,
				filetypes = { "javascriptreact", "typescriptreact" },
			},
		},
	})
	require("trouble").setup({})
	vim.keymap.set("n", "<leader>cx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "List diagnostics" })

	require("config.lsp_keymaps").setup()

	local capabilities = require("blink.cmp").get_lsp_capabilities()
	local missing_servers = {}

	local function setup_server(server_name)
		local server = vim.deepcopy(servers[server_name] or {})
		server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
		-- Neovim 0.12 owns server configuration; nvim-lspconfig supplies the defaults.
		vim.lsp.config(server_name, server)
		local command = vim.lsp.config[server_name].cmd
		local executable = type(command) == "table" and command[1] or nil
		if executable and vim.fn.executable(executable) == 1 then
			vim.lsp.enable(server_name)
		else
			-- Keep unavailable declarative servers from producing failed LSP startup attempts.
			table.insert(missing_servers, server_name)
		end
	end

	for server_name in pairs(servers) do
		setup_server(server_name)
	end

	if #missing_servers > 0 then
		vim.schedule(function()
			vim.notify("Missing Home Manager LSP tools: " .. table.concat(missing_servers, ", "), vim.log.levels.WARN)
		end)
	end
end

return M
