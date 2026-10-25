-- ┌────────────────────────────────────┐
-- │ :checkhealth init6                 │
-- └────────────────────────────────────┘
-- Reports what Nix installed for this editor and whether the tools the enabled
-- features rely on are on PATH. Disabled features and languages are reported
-- as information, never as errors.
local M = {}

local health = vim.health

-- Executables every variant installs (`core` in tools.nix).
local core_tools = { "rg", "file", "man", "tree-sitter" }

-- Adapters from the `debug` group that plugins/debug/ resolves by name.
local debug_tools = { "debugpy-adapter", "js-debug", "bash-debug-adapter", "local-lua-debug-adapter" }

local function check_executables(names)
	for _, name in ipairs(names) do
		if vim.fn.executable(name) == 1 then
			health.ok(name .. ": " .. vim.fn.exepath(name))
		else
			health.error(name .. " is not on PATH")
		end
	end
end

local function check_generated()
	health.start("init6: generated modules")
	for _, name in ipairs({ "init6.generated.palette", "init6.generated.features" }) do
		if pcall(require, name) then
			health.ok(name)
		else
			health.warn(name .. " is missing", {
				"spec.nix generates it; a Neovim generation built before it existed lacks it.",
				"Build or activate the current configuration, or run `nix run .#nvim`.",
			})
		end
	end
	health.info("Configuration: " .. (vim.g.init6_config_dir or vim.fn.stdpath("config")))
end

local function check_features(features, languages)
	health.start("init6: features")
	health.info("ai: " .. tostring(features.ai))
	health.info("debug: " .. tostring(features.debug))
	for _, language in ipairs(languages) do
		health.info("languages." .. language .. ": " .. tostring(features.language(language)))
	end
end

local function check_tools(features, server_languages)
	health.start("init6: tools")
	check_executables(core_tools)
	if features.ai then
		check_executables({ "claude" })
	else
		health.info("ai disabled: claude not expected")
	end
	if features.debug then
		check_executables(debug_tools)
	else
		health.info("debug disabled: debug adapters not expected")
	end

	local server_names = vim.tbl_keys(require("init6.config.lsp_servers"))
	table.sort(server_names)
	for _, server in ipairs(server_names) do
		local language = server_languages[server]
		if language and not features.language(language) then
			health.info(server .. ": languages." .. language .. " disabled")
		else
			local command = vim.lsp.config[server] and vim.lsp.config[server].cmd
			local executable = type(command) == "table" and command[1] or nil
			if not executable then
				health.info(server .. ": command is resolved at start")
			elseif vim.fn.executable(executable) == 1 then
				health.ok(server .. ": " .. executable)
			else
				health.error(server .. ": " .. executable .. " is not on PATH")
			end
		end
	end
end

function M.check()
	local features = require("init6.config.features")
	local server_languages = require("init6.plugins.lsp").server_languages

	-- Language families, taken from the server map; every family has a server.
	local seen, languages = {}, {}
	for _, language in pairs(server_languages) do
		if not seen[language] then
			seen[language] = true
			table.insert(languages, language)
		end
	end
	table.sort(languages)

	check_generated()
	check_features(features, languages)
	check_tools(features, server_languages)
end

return M
