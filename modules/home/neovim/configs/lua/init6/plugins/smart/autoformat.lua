local M = {}

-- The `tools.nix` language group that installs each filetype's formatters.
-- Filetypes of a disabled group get no Conform entry, so saving falls back to
-- LSP formatting quietly instead of reporting missing formatters.
local filetype_languages = {
	astro = "web",
	css = "web",
	graphql = "web",
	html = "web",
	javascript = "web",
	javascriptreact = "web",
	json = "web",
	jsonc = "web",
	less = "web",
	lua = "lua",
	markdown = "markdown",
	php = "php",
	python = "python",
	scss = "web",
	svelte = "web",
	toml = "web",
	typescript = "web",
	typescriptreact = "web",
	vue = "web",
	yaml = "yaml",
	zsh = "shell",
}

-- Project-local oxfmt configuration, which wins over the bundled fallback.
local oxfmt_config_files = {
	".oxfmtrc.json",
	".oxfmtrc.jsonc",
	"oxfmt.config.ts",
	"oxfmt.config.mts",
	"oxfmt.config.cts",
	"oxfmt.config.js",
	"oxfmt.config.mjs",
	"oxfmt.config.cjs",
}

function M.setup()
	local features = require("init6.config.features")
	-- oxlint applies its fixes before oxfmt formats the result. oxfmt leaves
	-- Svelte and Astro untouched, so those only get oxlint.
	local oxc = { "oxlint", "oxfmt" }
	-- Plain scripts also drop unused imports first. Vue and Svelte stay out:
	-- oxlint does not see their templates, so it would remove used imports.
	local typescript = { "oxlint_unused_imports", "oxlint", "oxfmt" }
	local formatters_by_ft = {
		astro = { "oxlint" },
		css = { "oxfmt" },
		graphql = { "oxfmt" },
		html = { "oxfmt" },
		javascript = typescript,
		javascriptreact = typescript,
		json = { "oxfmt" },
		jsonc = { "oxfmt" },
		less = { "oxfmt" },
		lua = { "stylua" },
		markdown = { "mdsf", "rumdl" },
		php = { "html_beautify", "mago_format" },
		python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
		scss = { "oxfmt" },
		svelte = { "oxlint" },
		toml = { "oxfmt" },
		typescript = typescript,
		typescriptreact = typescript,
		vue = oxc,
		yaml = { "yamlfmt" },
		zsh = { "shellharden", "shfmt" },
		-- Conform can also run multiple formatters sequentially
		-- python = { "isort", "black" },
		--
		-- You can use 'stop_after_first' to run the first available formatter from the list
		-- javascript = { "prettierd", "prettier", stop_after_first = true },
	}
	for filetype, language in pairs(filetype_languages) do
		if not features.language(language) then
			formatters_by_ft[filetype] = nil
		end
	end

	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- Do not autoformat when disable_autoformat is set to avoid messing
			-- up shared repos.
			-- Create a project-local .nvim.lua containing
			-- vim.g.disable_autoformat = true to the repo root
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			-- Files on a remote mount are often live; only format them on request.
			if require("init6.plugins.ui.remote").contains(vim.api.nvim_buf_get_name(bufnr)) then
				return
			end

			-- Disable "format_on_save lsp_fallback" for languages that don't
			-- have a well standardized coding style. You can add additional
			-- languages here or re-enable it for the disabled ones.
			local disable_filetypes = { c = true, cpp = true }
			local lsp_format_opt
			if disable_filetypes[vim.bo[bufnr].filetype] then
				lsp_format_opt = "never"
			else
				lsp_format_opt = "fallback"
			end
			return {
				timeout_ms = 500,
				lsp_format = lsp_format_opt,
			}
		end,
		formatters = {
			-- oxlint's no-unused-vars suggestion fix, from `tools.nix`. It runs
			-- apart from the oxlint step because oxlint applies nothing when
			-- --fix and --fix-suggestions are combined.
			oxlint_unused_imports = {
				meta = { description = "Delete unused imports with oxlint." },
				command = "oxlint-unused-imports",
				args = { "$FILENAME" },
				stdin = false,
			},
			oxfmt = {
				-- Projects without their own oxfmt configuration get the bundled
				-- fallback, which also sorts imports and Tailwind classes.
				prepend_args = function(_, ctx)
					local project_config = vim.fs.find(oxfmt_config_files, { upward = true, path = ctx.dirname })[1]
					if project_config then
						return {}
					end
					local config_dir = vim.g.init6_config_dir or vim.fn.stdpath("config")
					return { "-c", vim.fs.joinpath(config_dir, "oxfmtrc.json") }
				end,
			},
		},
		formatters_by_ft = formatters_by_ft,
	})
	vim.keymap.set({ "n", "v" }, "<leader>cf", function()
		require("conform").format({ async = true, lsp_format = "fallback" })
	end, { desc = "Format buffer/selection" })
end

return M
