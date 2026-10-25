-- ┌────────────────────────────────────┐
-- │ Nix-selected features              │
-- └────────────────────────────────────┘
-- `spec.nix` generates the `init6.generated.features` module from
-- `editor.neovim.features`; a disabled feature's plugins and executables are
-- not installed, so the configuration must not set them up. Without the module
-- (an older generation, or a checkout tested against one), everything is
-- treated as enabled, matching the option defaults.
local ok, generated = pcall(require, "init6.generated.features")
if not ok then
	generated = {}
end

local M = {
	ai = generated.ai ~= false,
	debug = generated.debug ~= false,
}

local languages = generated.languages or {}

--- Whether the tooling for a language family from `tools.nix` is installed.
---@param name string e.g. "lua", "web"
---@return boolean
function M.language(name)
	return languages[name] ~= false
end

return M
