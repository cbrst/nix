local M = {}

-- ┌─────────────────────────────┐
-- │ Explicit filetype setup     │
-- └─────────────────────────────┘
function M.setup()
	-- Keep this list explicit so enabled filetype behavior is discoverable and stable.
	require("init6.languages.lua").setup()
	require("init6.languages.markdown").setup()
end

return M
