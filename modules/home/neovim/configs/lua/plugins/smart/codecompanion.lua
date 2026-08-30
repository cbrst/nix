local M = {}

-- ┌────────────────────────────┐
-- │ CodeCompanion and OpenCode │
-- └────────────────────────────┘
function M.setup()
	require("codecompanion").setup({
		interactions = {
			-- ACP preserves OpenCode's CLI authentication, MCP servers, skills, and agents.
			chat = { adapter = "opencode" },
		},
		display = {
			-- Reuse the configured picker instead of adding another selection UI.
			action_palette = { provider = "telescope" },
		},
	})

	vim.keymap.set("n", "<leader>oll", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Open AI chat" })
	vim.keymap.set("x", "<leader>ola", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to AI context" })
	vim.keymap.set({ "n", "x" }, "<leader>olm", "<cmd>CodeCompanionActions<cr>", { desc = "Open AI action menu" })
	vim.keymap.set({ "n", "x" }, "<leader>olr", "<cmd>CodeCompanion<cr>", { desc = "Rewrite with AI" })
	vim.keymap.set("n", "<leader>olR", "<cmd>CodeCompanionCodeReview<cr>", { desc = "Review code with AI" })
end

return M
