local M = {}

-- ┌──────────────────────────────┐
-- │ Hex colour arithmetic        │
-- └──────────────────────────────┘
local function rgb(hex)
	hex = hex:gsub("^#", "")
	return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function hex(r, g, b)
	local function channel(value)
		return math.floor(math.min(math.max(value, 0), 255) + 0.5)
	end
	return string.format("#%02x%02x%02x", channel(r), channel(g), channel(b))
end

--- Mix `alpha` of `fg` over `bg` (alpha 1 returns `fg`).
---@param fg string
---@param bg string
---@param alpha number
---@return string
function M.blend(fg, bg, alpha)
	local fr, fg_, fb = rgb(fg)
	local br, bg_, bb = rgb(bg)
	return hex(alpha * fr + (1 - alpha) * br, alpha * fg_ + (1 - alpha) * bg_, alpha * fb + (1 - alpha) * bb)
end

function M.lighten(color, amount)
	return M.blend("#ffffff", color, amount)
end

function M.darken(color, amount)
	return M.blend("#000000", color, amount)
end

return M
