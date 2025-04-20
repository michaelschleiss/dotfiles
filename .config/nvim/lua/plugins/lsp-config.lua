return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
			ensure_installed = { "lua_ls", "pyright" },
		},
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			-- local cmp_nvim_lsp = require("cmp_nvim_lsp")
			-- local capabilities = vim.tbl_deep_extend(
			--   "force",
			--   {},
			--   vim.lsp.protocol.make_client_capabilities(),
			--   cmp_nvim_lsp.default_capabilities()
			-- )

			local lspconfig = require("lspconfig")

			lspconfig.lua_ls.setup({
				-- capabilities = capabilities
			})
			require("lspconfig").pyright.setup({
				settings = {
					pyright = {
						-- Using Ruff's import organizer
						disableOrganizeImports = true,
					},
					python = {
						analysis = {
							-- Ignore all files for analysis to exclusively use Ruff for linting
							ignore = { "*" },
						},
					},
				},
			})
			lspconfig.ruff.setup({})

			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {})
			vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
