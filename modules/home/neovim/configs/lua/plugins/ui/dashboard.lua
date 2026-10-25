local M = {}

-- ┌─────────────────────────────────────┐
-- │ Start screen fortunes               │
-- └─────────────────────────────────────┘
local fortunes = {
	"Type `:! sudo init 6` to exit.",
	"`:q!` — the only commitment-free relationship you'll ever have.",
	"You've used Vim for three years. Mostly to work out how to leave it.",
	"`hjkl`: because arrow keys are for people with free time.",
	"Vim is not hard. You are just in the wrong mode.",
	"`u` undoes everything except your life choices.",
	"Your mouse called. It misses you.",
	"`:wq` is how Vim users say goodbye. `ZZ` is how they say it faster.",
	"There are two kinds of people: those who have typed `:w` into a browser textarea, and liars.",
	"Emacs is a great operating system, lacking only a decent editor. (Yes, it's installed here too.)",
	"Recording `@q`… you will never remember what's in it.",
	"`.` is the most powerful key on your keyboard. Repeat after me.",
	"Somewhere, a `:%s/foo/bar/g` is about to go terribly wrong.",
	'`ci"` — because selecting text by hand is a cry for help.',
	"Escape is not a key. It is a way of life.",
	"The `q:` window is not a bug. It is a trap.",
	"Vim: turning `jjjjjjjjjj` into a personality since 1991.",
	"`:help` is free. Your dignity, after reading `:help`, is not.",
	"Ex mode, the editor's way of asking whether you really meant that.",
	"Real programmers set `'number'`. Brave ones set `'relativenumber'`.",
	"You have unsaved changes. You always have unsaved changes.",
	"Your config is declarative. Your muscle memory is not.",
	"Home Manager owns this config. You merely rent it.",
}

-- Wrap one fortune into evenly long lines so it fits the pane without orphans.
local function wrap(text, width)
	width = math.min(width, math.ceil(#text / math.ceil(#text / width)) + 6)
	local lines, line = {}, ""
	for word in text:gmatch("%S+") do
		if line ~= "" and #line + #word + 1 > width then
			table.insert(lines, line)
			line = word
		else
			line = line == "" and word or line .. " " .. word
		end
	end
	table.insert(lines, line)
	return table.concat(lines, "\n")
end

-- Drawn once per session: the Pokémon pane measures this pane by resolving it
-- again, and a resize should not reshuffle the quote either.
local quote = fortunes[math.random(#fortunes)]

local function fortune()
	return {
		text = { { wrap(quote, 54), hl = "SnacksDashboardFooter" } },
		align = "center",
		padding = 1,
	}
end

-- ┌─────────────────────────────────────┐
-- │ Header                              │
-- └─────────────────────────────────────┘
-- Mirror Neovim's own `:intro` header, mapped onto theme highlight groups.
local function header()
	local function line(chunks, hl)
		return { text = type(chunks) == "string" and { { chunks, hl = hl } } or chunks, align = "center" }
	end
	local function logo(n, mid, rest)
		return line({ { n, hl = "Special" }, { mid, hl = "String" }, { rest, hl = "String" } })
	end
	-- A function, not a shared table: snacks mutates items while laying them out.
	local function rule()
		return line(("─"):rep(44), "NonText")
	end

	return {
		padding = 2,
		logo("│", " ╲ ", "││"),
		logo("││", "╲╲", "││"),
		logo("││", " ╲ ", "│"),
		line(" "),
		line("NVIM v" .. tostring(vim.version()), "String"),
		rule(),
		line("Nvim is open source and freely distributable"),
		line("https://neovim.io/#chat", "Comment"),
		rule(),
	}
end

-- ┌─────────────────────────────────────┐
-- │ Actions                             │
-- └─────────────────────────────────────┘
local function telescope(picker, opts)
	return function()
		require("telescope.builtin")[picker](opts and opts() or nil)
	end
end

-- Match the `<leader>/` project search instead of always grepping from cwd.
local function project_cwd()
	local root = require("plugins.ui.vcs").context(0)
	return { cwd = root or vim.uv.cwd() }
end

-- Evaluated on every render so the label and visibility follow the cwd.
local function keys()
	local _, kind = require("plugins.ui.vcs").context(0)

	return {
		gap = 0,
		padding = 2,
		{
			icon = "\u{f002} ",
			key = "f",
			desc = "Find file",
			action = function()
				require("plugins.ui.telescope").find_files()
			end,
		},
		{
			icon = "\u{f022} ",
			key = "g",
			desc = "Search project",
			action = function()
				require("plugins.ui.telescope").live_grep(project_cwd())
			end,
		},
		{ icon = "\u{f0c5} ", key = "r", desc = "Recent files", action = telescope("oldfiles") },
		{ icon = "\u{f15b} ", key = "n", desc = "New buffer", action = ":ene | startinsert" },
		{
			icon = "\u{e725} ",
			key = "s",
			desc = kind == "jj" and "jj status" or "Git status",
			enabled = kind ~= nil,
			action = function()
				require("plugins.ui.vcs").open(0, "status")
			end,
		},
		{ icon = "\u{f07b} ", key = "e", desc = "File tree", action = ":Neotree toggle reveal_force_cwd" },
		{
			icon = "\u{ec10} ",
			key = "c",
			desc = "Claude Code",
			enabled = vim.fn.executable("claude") == 1,
			action = function()
				require("plugins.smart.claudecode").toggle()
			end,
		},
		{ icon = "\u{f426} ", key = "q", desc = "Quit", action = ":qa" },
	}
end

-- Hide the whole block, title included, when the cwd has no history yet.
local function recent_files()
	local files = Snacks.dashboard.sections.recent_files({ cwd = true, limit = 5 })()
	if #files == 0 then
		return
	end
	return {
		{ icon = "\u{f017} ", title = "Recent files here", padding = 1 },
		vim.tbl_extend("force", files, { indent = 2, padding = 1 }),
	}
end

-- ┌─────────────────────────────────────┐
-- │ Pokémon pane                        │
-- └─────────────────────────────────────┘
local main_pane = { header, keys, recent_files, fortune }

-- Small sprites are at most this many lines tall.
local sprite_height = 28

-- Snacks top-aligns panes, so measure the main pane with snacks' own
-- resolver/formatter; `dashboard-pokemon` then centres the sprite in that box.
-- It never exits while shown, so there is no cache: every launch shows a
-- fresh random Pokémon.
local function pokemon(self)
	local columns = self.opts.width + self.opts.pane_gap
	local side_by_side = self._size.width + self.opts.pane_gap >= 2 * columns

	local height = 0
	if side_by_side then
		for _, item in ipairs(self:resolve(main_pane)) do
			height = height + #self:format(item)
		end
	end

	return Snacks.dashboard.sections.terminal({
		cmd = ("dashboard-pokemon %d %d"):format(height, self.opts.width),
		ttl = 0,
		height = math.max(height, sprite_height),
	})(self)
end

-- ┌─────────────────────────────────────┐
-- │ Snacks dashboard options            │
-- └─────────────────────────────────────┘
function M.opts()
	return {
		enabled = true,
		formats = {
			-- Recent files are scoped to the cwd, so show them relative to it.
			file = function(item, ctx)
				local fname = vim.fn.fnamemodify(item.file, ":~:.")
				if ctx.width and #fname > ctx.width then
					fname = vim.fn.pathshorten(fname)
				end
				local dir, file = fname:match("^(.*)/(.+)$")
				return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
			end,
		},
		sections = {
			header,
			keys,
			recent_files,
			fortune,
			{ pane = 2, enabled = vim.fn.executable("dashboard-pokemon") == 1, pokemon },
		},
	}
end

-- The dashboard is not an editing surface, so keep editing decorations off it.
function M.setup()
	vim.api.nvim_create_autocmd("User", {
		desc = "Disable editing decorations on the dashboard",
		group = vim.api.nvim_create_augroup("config-dashboard", { clear = true }),
		-- The startup buffer is reused without a FileType event, so use the
		-- dashboard's own event and find its buffer by filetype.
		pattern = "SnacksDashboardOpened",
		callback = function()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].filetype == "snacks_dashboard" and vim.bo[buf].buftype ~= "terminal" then
					vim.b[buf].miniindentscope_disable = true
					vim.b[buf].minianimate_disable = true
					vim.api.nvim_buf_call(buf, MiniIndentscope.undraw)
				end
			end
		end,
	})
end

return M
