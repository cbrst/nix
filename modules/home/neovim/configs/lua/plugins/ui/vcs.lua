local M = {}

local cache = {}
local setup_done = false

local actions = {
	status = {},
	commit = { git = "commit", jj = "commit" },
	diff = { git = "diff", jj = "diff" },
	fetch = { git = "fetch", jj = "fetch" },
	log = { git = "log", jj = "log" },
	push = { git = "push", jj = "push" },
	rebase = { git = "rebase", jj = "rebase" },
	remote = { git = "remote", jj = "remote" },
	branch = { git = "branch", jj = "bookmark" },
	worktree = { git = "worktree", jj = "workspace" },
}

local action_names = vim.tbl_keys(actions)
table.sort(action_names)

function M.context(bufnr)
	bufnr = bufnr or 0
	local jj_root = vim.fs.root(bufnr, ".jj")
	local git_root = vim.fs.root(bufnr, ".git")
	if not jj_root and not git_root then
		return
	end

	if jj_root and (not git_root or #jj_root >= #git_root) then
		return jj_root, "jj"
	end

	return git_root, "git"
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
	local root, kind = M.context(bufnr)
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
	local root, kind = M.context(bufnr or 0)
	if root then
		refresh(root, kind)
	end
end

function M.open(bufnr, action)
	local root, kind = M.context(bufnr or 0)
	if not root then
		vim.notify("No Git or jj repository found", vim.log.levels.WARN)
		return
	end

	action = action == "" and "status" or action or "status"
	local backend_action = actions[action]
	if not backend_action then
		vim.notify("Unknown VCS action: " .. action, vim.log.levels.ERROR)
		return
	end

	local options = { cwd = root }
	if action ~= "status" then
		options[1] = backend_action[kind]
	end
	require(kind == "jj" and "neojj" or "neogit").open(options)
end

function M.setup()
	if setup_done then
		return
	end
	setup_done = true

	vim.g.diffs = {
		integrations = {
			gitsigns = true,
			neogit = true,
			neojj = true,
			telescope = true,
		},
	}

	local shared_config = {
		kind = "tab",
		integrations = {
			codediff = false,
			diffview = false,
			snacks = true,
			telescope = false,
		},
		popup = { kind = "split" },
		treesitter_diff_highlight = false,
		word_diff_highlight = false,
	}

	local neogit_config = vim.deepcopy(shared_config)
	neogit_config.mappings = {
		popup = {
			["m"] = "RemotePopup",
			["M"] = "MergePopup",
			["p"] = "PushPopup",
			["P"] = "PullPopup",
		},
	}
	require("neogit").setup(neogit_config)
	require("neojj").setup(vim.deepcopy(shared_config))

	local mappings = {
		{ "<leader>gg", "status", "VCS status" },
		{ "<leader>gc", "commit", "VCS commit" },
		{ "<leader>gd", "diff", "VCS diff" },
		{ "<leader>gf", "fetch", "VCS fetch" },
		{ "<leader>gl", "log", "VCS log" },
		{ "<leader>gp", "push", "VCS push" },
		{ "<leader>gr", "rebase", "VCS rebase" },
		{ "<leader>gm", "remote", "VCS remotes" },
		{ "<leader>gb", "branch", "VCS branches/bookmarks" },
		{ "<leader>gw", "worktree", "VCS worktrees/workspaces" },
	}
	for _, mapping in ipairs(mappings) do
		local keys, action, description = mapping[1], mapping[2], mapping[3]
		vim.keymap.set("n", keys, function()
			M.open(0, action)
		end, { desc = description })
	end

	vim.api.nvim_create_user_command("Vcs", function(command)
		M.open(0, command.args)
	end, {
		nargs = "?",
		complete = function(prefix)
			return vim.tbl_filter(function(action)
				return vim.startswith(action, prefix)
			end, action_names)
		end,
		desc = "Open the repository-aware VCS interface",
	})

	local group = vim.api.nvim_create_augroup("ConfigVcsStatus", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained", "ShellCmdPost" }, {
		group = group,
		callback = function(args)
			local bufnr = args.buf ~= 0 and args.buf or vim.api.nvim_get_current_buf()
			M.refresh(bufnr)
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = {
			"NeogitStatusRefreshed",
			"NeogitCommitComplete",
			"NeogitPushComplete",
			"NeogitPullComplete",
			"NeogitFetchComplete",
			"NeogitRebase",
			"NeojjStatusRefreshed",
			"NeojjCommitComplete",
			"NeojjPushComplete",
			"NeojjFetchComplete",
			"NeojjSquashComplete",
		},
		callback = function()
			for _, status in pairs(cache) do
				refresh(status.root, status.kind)
			end
		end,
	})
end

return M
