-- Claude Code commit-message drafts for NeoJJ description buffers. NeoJJ sets
-- JJ_EDITOR, which bypasses the jj-commit-editor wrapper used on the CLI.
local M = {}

local command = "claude-commit-draft"

local function first_comment_line(lines)
	for index, line in ipairs(lines) do
		if line:match("^JJ:") then
			return index
		end
	end
	return #lines + 1
end

local function has_description(lines)
	for index = 1, first_comment_line(lines) - 1 do
		if lines[index]:match("%S") then
			return true
		end
	end
	return false
end

local function draft_diff(lines)
	for index, line in ipairs(lines) do
		if line == "JJ: ignore-rest" then
			return table.concat(lines, "\n", index + 1)
		end
	end
	return ""
end

local function notify(message, level)
	vim.notify("Claude Code commit draft: " .. message, level or vim.log.levels.INFO)
end

local function draft(buffer)
	-- Filetype detection and NeoJJ both set the filetype; draft only once.
	if vim.b[buffer].commit_draft_started then
		return
	end
	vim.b[buffer].commit_draft_started = true

	local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	if has_description(lines) then
		return
	end

	local diff = draft_diff(lines)
	if not diff:match("%S") then
		return
	end

	notify("generating…")
	vim.system({ command }, { stdin = diff, text = true }, function(result)
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(buffer) then
				return
			end

			local message = vim.trim(result.stdout or "")
			if result.code ~= 0 then
				local reason = vim.trim((message .. " " .. (result.stderr or "")):gsub("%s+", " "))
				notify(("failed (exit %d): %s"):format(result.code, reason), vim.log.levels.WARN)
				return
			end
			if message == "" then
				notify("claude returned an empty message.", vim.log.levels.WARN)
				return
			end
			if has_description(vim.api.nvim_buf_get_lines(buffer, 0, -1, false)) then
				notify("description already edited; draft discarded.", vim.log.levels.WARN)
				return
			end

			local draft_lines = vim.split(message, "\n", { plain = true })
			table.insert(draft_lines, "")
			-- Replace the blank lines above the JJ: footer with the draft.
			local footer = first_comment_line(vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
			vim.api.nvim_buf_set_lines(buffer, 0, footer - 1, false, draft_lines)
			notify("inserted.")
		end)
	end)
end

function M.setup()
	-- jj-commit-editor already ran the hook before opening this Neovim.
	if vim.env.CLAUDE_COMMIT_DRAFT_DONE or vim.fn.executable(command) ~= 1 then
		return
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("init6-commit-draft", { clear = true }),
		pattern = "jjdescription",
		callback = function(event)
			draft(event.buf)
		end,
		desc = "Insert a Claude Code draft into empty jj descriptions",
	})
end

return M
