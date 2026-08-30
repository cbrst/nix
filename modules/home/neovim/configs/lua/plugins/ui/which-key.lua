local M = {}

function M.setup()
	require("which-key").setup({
		icons = {
			mappings = vim.g.have_nerd_font,
			keys = vim.g.have_nerd_font and {} or {
				Up = "<Up> ",
				Down = "<Down> ",
				Left = "<Left> ",
				Right = "<Right> ",
				C = "<C-…> ",
				M = "<M-…> ",
				D = "<D-…> ",
				S = "<S-…> ",
				CR = "<CR> ",
				Esc = "<Esc> ",
				ScrollWheelDown = "<ScrollWheelDown> ",
				ScrollWheelUp = "<ScrollWheelUp> ",
				NL = "<NL> ",
				BS = "<BS> ",
				Space = "<Space> ",
				Tab = "<Tab> ",
				F1 = "<F1>",
				F2 = "<F2>",
				F3 = "<F3>",
				F4 = "<F4>",
				F5 = "<F5>",
				F6 = "<F6>",
				F7 = "<F7>",
				F8 = "<F8>",
				F9 = "<F9>",
				F10 = "<F10>",
				F11 = "<F11>",
				F12 = "<F12>",
			},
		},
		spec = {
			{ "<leader>b", group = "Buffer" },
			{ "<leader>c", group = "Code", mode = { "n", "x" } },
			{ "<leader>f", group = "File" },
			{ "<leader>g", group = "Git", mode = { "n", "x" } },
			{ "<leader>h", group = "Help" },
			{ "<leader>o", group = "Open", mode = { "n", "t", "x" } },
			{ "<leader>ol", group = "LLM", mode = { "n", "x" } },
			{ "<leader>q", group = "Quit/session" },
			{ "<leader>s", group = "Search" },
			{ "<leader>t", group = "Toggle", mode = { "n", "t" } },
			{ "<leader>w", group = "Window" },
		},
	})
end

return M
