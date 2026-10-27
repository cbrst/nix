local M = {}

-- ╭───────────────────────────────╮
-- │ Remote hosts mounted by SSHFS │
-- ╰───────────────────────────────╯

-- remote-sshfs mounts each host at `<mount_dir><host>`, so every local tool
-- (Neo-tree, Telescope, LSP) sees the remote files as ordinary paths.
M.mount_dir = vim.fs.joinpath(vim.fn.expand("~"), ".sshfs") .. "/"

-- The local working directory before connecting, restored on disconnect.
local local_cwd

-- Whether an absolute path lies on a remote mount. This compares strings only:
-- a stat on the mount would be a network round trip.
function M.contains(path)
	return path ~= nil and path ~= "" and vim.startswith(vim.fs.normalize(path), M.mount_dir)
end

-- Neo-tree reads this flag on each scan. Git status is off while the working
-- directory is on a mount: a remote site is edited in place, not through Git.
local function sync_git_status()
	require("neo-tree").ensure_config().enable_git_status = not M.contains(vim.fn.getcwd())
end

local function disconnect()
	require("remote-sshfs.api").disconnect()
	if local_cwd and M.contains(vim.fn.getcwd()) then
		vim.cmd.cd(vim.fn.fnameescape(local_cwd))
	end
end

function M.setup()
	require("remote-sshfs").setup({
		connections = {
			-- The plugin lists hosts from these files and does not follow
			-- `Include`, so the included host file is named explicitly.
			ssh_configs = {
				vim.fn.expand("~/.ssh/config"),
				vim.fn.expand("~/.ssh/hosts"),
				"/etc/ssh/ssh_config",
			},
			-- Keepalives make ssh exit within ~45 s of a dead link, so `reconnect`
			-- takes over instead of file access on the mount (and with it the
			-- editor) blocking until TCP gives up. The full list replaces the
			-- plugin's defaults.
			sshfs_args = {
				"-o reconnect",
				"-o ConnectTimeout=5",
				"-o ServerAliveInterval=15",
				"-o ServerAliveCountMax=3",
			},
		},
		mounts = { base_dir = M.mount_dir },
		ui = {
			picker = "telescope",
			-- The plugin's y/n prompts use vim.ui.input from inside the Telescope
			-- action, which loses focus to the editing window. Choosing the host
			-- already confirms it, and the remaining prompts (unknown host keys)
			-- use vim.ui.select, a Telescope picker, instead.
			select_prompts = true,
			confirm = { connect = false },
		},
	})
	require("telescope").load_extension("remote-sshfs")

	local group = vim.api.nvim_create_augroup("init6-remote", { clear = true })
	vim.api.nvim_create_autocmd("DirChangedPre", {
		group = group,
		callback = function()
			local cwd = vim.fn.getcwd()
			if M.contains(vim.v.event.directory) and not M.contains(cwd) then
				local_cwd = cwd
			end
		end,
	})
	vim.api.nvim_create_autocmd("DirChanged", { group = group, callback = sync_git_status })
	if M.contains(vim.fn.getcwd()) then
		sync_git_status()
	end

	local api = require("remote-sshfs.api")
	vim.keymap.set("n", "<leader>Rc", api.connect, { desc = "Connect to host" })
	vim.keymap.set("n", "<leader>Rd", disconnect, { desc = "Disconnect" })
	vim.keymap.set("n", "<leader>Re", api.edit, { desc = "Edit SSH config" })
	-- Run find and grep on the host instead of through the mount; they need
	-- rg (or fd/find) there.
	vim.keymap.set("n", "<leader>Rf", api.find_files, { desc = "Find files on host" })
	vim.keymap.set("n", "<leader>Rg", api.live_grep, { desc = "Grep on host" })
end

return M
