local M = {}
local icons = require("utils.icons")

-- ┌─────────────────────────────┐
-- │ Moody-inspired statusline   │
-- └─────────────────────────────┘
local function mode_color(mode)
	local palette = {
		n = { label = " N ", fg = "#5ad4e6", bg = "#2d4649" },
		i = { label = " I ", fg = "#7bd88f", bg = "#344638" },
		v = { label = " V ", fg = "#fce566", bg = "#4d492f" },
		V = { label = " V ", fg = "#fce566", bg = "#4d492f" },
		["\22"] = { label = " V ", fg = "#fce566", bg = "#4d492f" },
		R = { label = " R ", fg = "#fc618d", bg = "#4d2e37" },
		c = { label = " E ", fg = "#948ae3", bg = "#393748" },
	}
	return palette[mode] or palette.n
end

function M.setup()
	local colors = require("config.ui_colors")
	local conditions = require("heirline.conditions")
	local utils = require("heirline.utils")
	local vcs = require("plugins.ui.vcs")

	local mode = {
		init = function(self)
			self.mode = vim.fn.mode(1)
		end,
		provider = function(self)
			return mode_color(self.mode).label
		end,
		hl = function(self)
			local state = mode_color(self.mode)
			return { fg = state.fg, bg = state.bg, bold = true }
		end,
	}

	local mode_separator = {
		init = function(self)
			self.mode = vim.fn.mode(1)
		end,
		provider = "",
		hl = function(self)
			return { fg = colors.get().tab, bg = mode_color(self.mode).bg }
		end,
	}

	local filename = {
		provider = function()
			local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
			return " " .. (name == "" and "[No Name]" or name) .. " "
		end,
		{
			condition = function()
				return not (not vim.bo.modifiable or vim.bo.readonly) and vim.bo.modified
			end,
			provider = "󰏫 ",
			hl = { fg = mode_color("v").fg },
		},
		{
			condition = function()
				return (not vim.bo.modifiable or vim.bo.readonly) and not vim.bo.modified
			end,
			provider = " ",
			hl = { fg = mode_color("c").fg },
		},
		{
			condition = function()
				return (not vim.bo.modifiable or vim.bo.readonly) and vim.bo.modified
			end,
			provider = " ",
			hl = { fg = mode_color("R").fg },
		},
		hl = function()
			return { bg = colors.get().tab, fg = colors.get().fg, bold = true }
		end,
	}

	local divider = {
		provider = "  ",
		hl = function()
			return { bg = colors.get().bar, fg = colors.get().tab, bold = true }
		end,
	}

	local filename_separator = {
		provider = "",
		hl = function()
			return { fg = colors.get().tab, bg = colors.get().bar }
		end,
	}

	local filetype = {
		provider = function()
			return " " .. (vim.bo.filetype == "" and "text" or vim.bo.filetype)
		end,
		hl = function()
			return { bg = colors.get().bar, fg = colors.get().muted }
		end,
	}

	local label_separator_pre = {
		provider = "",
		hl = function()
			return { fg = colors.get().bar, bg = colors.get().tab }
		end,
	}

	local label_separator_post = {
		provider = "",
		hl = function()
			return { fg = colors.get().tab, bg = colors.get().bar }
		end,
	}

	local vcs_segment = {
		condition = function()
			return vcs.get(0) ~= nil
		end,
		init = function(self)
			self.vcs = vcs.get(0)
		end,
		on_click = {
			callback = function()
				vcs.open(0)
			end,
			name = "heirline_vcs",
		},
		hl = function()
			return { bg = colors.get().tab, fg = colors.get().fg }
		end,
		{
			provider = function(self)
				local status = self.vcs
				if status.kind == "git" then
					return status.head and "  " .. status.head or ""
				end
				if not status.available then
					return ""
				end

				return "  " .. (status.bookmarks ~= "" and status.bookmarks or "") .. "@" .. status.prefix
			end,
		},
		{
			condition = function(self)
				return self.vcs.kind == "jj" and self.vcs.available and self.vcs.rest ~= ""
			end,
			provider = function(self)
				return self.vcs.rest
			end,
			hl = function()
				return { bg = colors.get().tab, fg = colors.get().muted }
			end,
		},
		{
			provider = function(self)
				local status = self.vcs
				if (status.kind == "git" and not status.head) or (status.kind == "jj" and not status.available) then
					return ""
				end

				local changes = {}
				if status.available and status.added > 0 then
					table.insert(changes, "+" .. status.added)
				end
				if status.available and status.changed > 0 then
					table.insert(changes, "~" .. status.changed)
				end
				if status.available and status.removed > 0 then
					table.insert(changes, "-" .. status.removed)
				end

				return (#changes > 0 and " " .. table.concat(changes, " ") or "") .. " "
			end,
		},
	}

	local diagnostics = {
		condition = conditions.has_diagnostics,
		update = { "DiagnosticChanged", "BufEnter" },

		static = {
			icon_error = icons.diagnostics.error,
			icon_warning = icons.diagnostics.warning,
			icon_info = icons.diagnostics.info,
			icon_hint = icons.diagnostics.hint,
		},

		init = function(self)
			self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
			self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
			self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
			self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		end,

		on_click = {
			callback = function()
				require("trouble").toggle({ mode = "diagnostics" })
			end,
			name = "heirline_diagnostics",
		},

		{
			provider = function(self)
				return self.errors > 0 and (self.icon_error .. self.errors .. " ")
			end,
			hl = { fg = utils.get_highlight("DiagnosticError").fg },
		},
		{
			provider = function(self)
				return self.warnings > 0 and (self.icon_warning .. self.warnings .. " ")
			end,
			hl = { fg = utils.get_highlight("DiagnosticWarn").fg },
		},
		{
			provider = function(self)
				return self.info > 0 and (self.icon_info .. self.info .. " ")
			end,
			hl = { fg = utils.get_highlight("DiagnosticInfo").fg },
		},
		{
			provider = function(self)
				return self.hints > 0 and (self.icon_hint .. self.hints .. " ")
			end,
			hl = { fg = utils.get_highlight("DiagnosticHint").fg },
		},
	}

	local lsp = {
		condition = conditions.lsp_attached,
		update = { "LspAttach", "LspDetach", "BufEnter" },
		provider = function()
			local names = vim.tbl_map(function(client)
				return client.name
			end, vim.lsp.get_clients({ bufnr = 0 }))

			return " " .. table.concat(names, ", ") .. " "
		end,
		hl = function()
			return { bg = colors.get().bar, fg = colors.get().muted }
		end,
	}

	local position = {
		provider = " %3l:%-2c %P ",
		hl = function()
			return { bg = colors.get().bar, fg = colors.get().fg }
		end,
	}

	require("heirline").setup({
		statusline = {
			mode,
			mode_separator,
			filename,
			filename_separator,
			filetype,
			divider,
			diagnostics,
			{ provider = "%=" },
			lsp,
			label_separator_pre,
			vcs_segment,
			label_separator_post,
			position,
		},
	})
end

return M
