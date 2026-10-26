local M = {}

-- ┌──────────────────────────────────────┐
-- │ Dim brackets that span several lines │
-- └──────────────────────────────────────┘
-- A bracket pair whose ends sit on different lines frames a block rather than
-- an expression, so both ends are drawn with `Init6BlockBracket`. Pairs come
-- from Treesitter: an opener and the matching closer among one node's
-- anonymous children. `vim.g.init6_dim_block_brackets = false` turns it off.

local namespace = vim.api.nvim_create_namespace("init6-block-brackets")
local closer_of = { ["("] = ")", ["["] = "]", ["{"] = "}" }
local is_closer = { [")"] = true, ["]"] = true, ["}"] = true }

-- Window id to { row = { col, ... } } for the redraw in progress.
local marks = {}

local function enabled()
	return vim.g.init6_dim_block_brackets ~= false
end

-- Record `node`'s column on its row. A closing bracket also claims a
-- semicolon right after it, as in `});`.
local function add(rows, node, top, bottom, closing)
	local row, col = node:start()
	if row >= top and row <= bottom then
		rows[row] = rows[row] or {}
		table.insert(rows[row], { col = col, closing = closing })
	end
end

-- Pair the brackets among `node`'s children, then descend into the children
-- that overlap rows `top` to `bottom`.
local function collect(node, top, bottom, rows)
	local openers = {}
	for child in node:iter_children() do
		local kind = child:type()
		if not child:named() and closer_of[kind] then
			table.insert(openers, child)
		elseif not child:named() and is_closer[kind] then
			for i = #openers, 1, -1 do
				local opener = openers[i]
				if closer_of[opener:type()] == kind then
					for j = #openers, i, -1 do
						openers[j] = nil
					end
					if opener:start() ~= child:start() then
						add(rows, opener, top, bottom, false)
						add(rows, child, top, bottom, true)
					end
					break
				end
			end
		end

		local start_row, _, end_row = child:range()
		if child:child_count() > 0 and end_row >= top and start_row <= bottom then
			collect(child, top, bottom, rows)
		end
	end
end

function M.toggle()
	vim.g.init6_dim_block_brackets = not enabled()
	vim.cmd("redraw!")
	vim.notify("Block bracket dimming " .. (enabled() and "on" or "off"))
end

function M.setup()
	vim.api.nvim_set_decoration_provider(namespace, {
		on_win = function(_, win, buf, top, bottom)
			marks[win] = nil
			-- Reuse the trees the Treesitter highlighter keeps current.
			local highlighter = vim.treesitter.highlighter.active[buf]
			if not enabled() or not highlighter then
				return false
			end
			local rows = {}
			highlighter.tree:for_each_tree(function(tree)
				collect(tree:root(), top, bottom, rows)
			end)
			marks[win] = rows
			return next(rows) ~= nil
		end,
		on_line = function(_, win, buf, row)
			local brackets = marks[win] and marks[win][row]
			if not brackets then
				return
			end
			local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
			for _, bracket in ipairs(brackets) do
				local col = bracket.col
				local width = (bracket.closing and line:sub(col + 2, col + 2) == ";") and 2 or 1
				vim.api.nvim_buf_set_extmark(buf, namespace, row, col, {
					end_col = col + width,
					hl_group = "Init6BlockBracket",
					ephemeral = true,
					-- Above Treesitter's @punctuation.bracket.
					priority = vim.hl.priorities.treesitter + 10,
				})
			end
		end,
	})

	vim.keymap.set("n", "<leader>tB", M.toggle, { desc = "Toggle dimming of multi-line brackets" })
end

return M
