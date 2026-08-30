local M = {}

local cache = {}
local setup_done = false

local function context(bufnr)
	local root = vim.fs.root(bufnr or 0, { ".jj", ".git" })
	if not root then
		return
	end

	return root, vim.uv.fs_stat(root .. "/.jj") and "jj" or "git"
end

local function count_hunks(patch)
	local counts = { added = 0, changed = 0, removed = 0 }

	for old_count, new_count in patch:gmatch("@@ %-%d+,?(%d*) %+%d+,?(%d*) @@") do
		old_count = tonumber(old_count) or 1
		new_count = tonumber(new_count) or 1

		local changed = math.min(old_count, new_count)
		counts.changed = counts.changed + changed
		counts.added = counts.added + new_count - changed
		counts.removed = counts.removed + old_count - changed
	end

	return counts
end

local function refresh(root, kind)
	local key = kind .. ":" .. root
	local status = cache[key] or { root = root, kind = kind }
	cache[key] = status

	if status.pending then
		return
	end
	status.pending = true

	local command
	if kind == "jj" then
		command = {
			"jj",
			"log",
			"-r",
			"@",
			"--no-graph",
			"--color",
			"never",
			"-T",
			'local_bookmarks.map(|b| b.name()).join(",")'
				.. ' ++ "\\t" ++ change_id.shortest(8).prefix()'
				.. ' ++ "\\t" ++ change_id.shortest(8).rest()'
				.. ' ++ "\\n" ++ diff.git(0)',
		}
	else
		command = {
			"git",
			"diff",
			"--no-ext-diff",
			"--no-color",
			"--unified=0",
			"--",
		}
	end

	vim.system(command, { cwd = root, text = true }, function(result)
		vim.schedule(function()
			status.pending = false
			status.ready = true
			status.available = result.code == 0

			local patch = result.stdout
			if status.available and kind == "jj" then
				local metadata
				metadata, patch = result.stdout:match("^([^\n]*)\n(.*)$")
				if metadata then
					status.bookmarks, status.prefix, status.rest = metadata:match("^([^\t]*)\t([^\t]*)\t([^\t]*)$")
				end
				status.available = status.prefix ~= nil
			end

			if status.available then
				local counts = count_hunks(patch)
				status.added = counts.added
				status.changed = counts.changed
				status.removed = counts.removed
			end

			vim.cmd.redrawstatus()
		end)
	end)
end

function M.get(bufnr)
	bufnr = bufnr or 0
	local root, kind = context(bufnr)
	if not root then
		return
	end

	local key = kind .. ":" .. root
	local status = cache[key]
	if not status then
		status = { root = root, kind = kind }
		cache[key] = status
		refresh(root, kind)
	end

	if kind == "git" then
		local gitsigns = vim.b[bufnr].gitsigns_status_dict
		status.head = gitsigns and gitsigns.head
	end

	return status
end

function M.refresh(bufnr)
	local root, kind = context(bufnr or 0)
	if root then
		refresh(root, kind)
	end
end

function M.open(bufnr)
	local root, kind = context(bufnr or 0)
	if not root then
		return
	end

	require("snacks").terminal.toggle(kind == "jj" and "blazingjj" or "lazygit", {
		cwd = root,
		win = {
			style = "terminal",
			position = "bottom",
			height = 0.4,
		},
	})
end

function M.setup()
	if setup_done then
		return
	end
	setup_done = true

	local group = vim.api.nvim_create_augroup("ConfigVcsStatus", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained", "ShellCmdPost" }, {
		group = group,
		callback = function(args)
			local bufnr = args.buf ~= 0 and args.buf or vim.api.nvim_get_current_buf()
			M.refresh(bufnr)
		end,
	})
end

return M
