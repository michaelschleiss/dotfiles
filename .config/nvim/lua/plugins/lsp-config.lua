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
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "pyright", "ruff", "clangd", "taplo", "texlab", "ltex" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_nvim_lsp.default_capabilities()
			)

			-- Configure LSP servers using nvim 0.11 native API
			-- DISABLED: texlab conflicts with zotcite citation completions
			-- vim.lsp.config("texlab", {
			-- 	cmd = { "texlab" },
			-- 	filetypes = { "tex", "plaintex", "bib" },
			-- 	root_markers = { ".latexmkrc", ".texlabroot", "Tectonic.toml", ".git" },
			-- 	capabilities = capabilities,
			-- 	settings = {
			-- 		texlab = {
			-- 			build = {
			-- 				executable = "latexmk",
			-- 				args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "-outdir=build", "%f" },
			-- 				onSave = false,
			-- 				auxDirectory = "build",
			-- 				logDirectory = "build",
			-- 				pdfDirectory = "build",
			-- 				useFileList = true,
			-- 			},
			-- 			chktex = {
			-- 				onOpenAndSave = true,
			-- 				onEdit = false,
			-- 			},
			-- 		},
			-- 	},
			-- })
			-- vim.lsp.enable("texlab")

			-- DISABLED: ltex - testing if it blocks zotcite
			-- vim.lsp.config("ltex", {
			-- 	cmd = { "ltex-ls" },
			-- 	filetypes = { "tex", "plaintex", "bib", "markdown", "text" },
			-- 	root_markers = { ".git" },
			-- 	capabilities = capabilities,
			-- 	settings = {
			-- 		ltex = {
			-- 			language = "en-US",
			-- 			enabled = { "latex", "bibtex", "markdown", "text" },
			-- 			additionalRules = {
			-- 				enablePickyRules = true,
			-- 				motherTongue = "de-DE", -- Detect false friends for German speakers
			-- 			},
			-- 			completionEnabled = true,
			-- 			diagnosticSeverity = "information",
			-- 			sentenceCacheSize = 5000,
			-- 		},
			-- 	},
			-- })
			-- vim.lsp.enable("ltex")

			-- Setup ltex_extra via LspAttach autocommand
			-- vim.api.nvim_create_autocmd("LspAttach", {
			-- 	callback = function(args)
			-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
			-- 		if client and client.name == "ltex" then
			-- 			require("ltex_extra").setup({
			-- 				load_langs = { "en-US", "de-DE" },
			-- 				path = vim.fn.expand("~") .. "/.local/share/ltex",
			-- 			})
			-- 		end
			-- 	end,
			-- })

			vim.lsp.config("pyright", {
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", ".git" },
				capabilities = capabilities,
				settings = {
					pyright = { disableOrganizeImports = true },
					python = {
						analysis = {
							typeCheckingMode = "basic",
							diagnosticMode = "workspace",
						},
					},
				},
			})
			vim.lsp.enable("pyright")

			vim.lsp.config("ruff", {
				cmd = { "ruff", "server" },
				filetypes = { "python" },
				root_markers = { "pyproject.toml", "ruff.toml", ".git" },
				capabilities = capabilities,
			})
			vim.lsp.enable("ruff")

			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = { ".luarc.json", ".stylua.toml", ".git" },
				capabilities = capabilities,
			})
			vim.lsp.enable("lua_ls")

			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--suggest-missing-includes",
					"--clang-tidy",
					"--header-insertion=iwyu",
				},
				filetypes = { "c", "cpp", "objc", "objcpp" },
				root_markers = { "compile_commands.json", ".git" },
				capabilities = capabilities,
			})
			vim.lsp.enable("clangd")

			vim.lsp.config("taplo", {
				cmd = { "taplo", "lsp", "stdio" },
				filetypes = { "toml" },
				root_markers = { ".taplo.toml", ".git" },
				capabilities = capabilities,
				settings = {
					taplo = {
						formatting = { columnWidth = 100, indentString = "    " },
					},
				},
			})
			vim.lsp.enable("taplo")

			-- Filter out noisy texlab diagnostics, but leave other LSPs (like ltex) untouched.
			do
				local orig_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]

				vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
					if result and result.diagnostics then
						local client = vim.lsp.get_client_by_id(ctx.client_id)
						if client and client.name == "texlab" then
							result.diagnostics = vim.tbl_filter(function(d)
								return d.message ~= "Undefined reference" and d.message ~= "Unused label"
							end, result.diagnostics)
						end
					end
					return orig_publish(err, result, ctx, config)
				end
			end

			-- Keymaps
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "K", function()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then return end
				local encoding = clients[1].offset_encoding or "utf-16"
				vim.lsp.buf_request(0, "textDocument/hover", vim.lsp.util.make_position_params(0, encoding), function(err, result, ctx, config)
					if not result or not result.contents then return end
					if type(result.contents) ~= "string" and type(result.contents) ~= "table" then return end
					if type(result.contents) == "table" then
						local c = result.contents
						if not c.kind and not c.value and not c[1] and not c.language then return end
					end
					vim.lsp.handlers.hover(err, result, ctx, config)
				end)
			end, { desc = "Safe hover" })
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {})
			vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, {})
			vim.keymap.set("n", "<leader>q", function()
				vim.diagnostic.setqflist()
				vim.cmd("copen")
			end, { desc = "Diagnostics to quickfix" })
			vim.keymap.set("n", "<leader>Q", ":cexpr system('pyright') | copen<cr>", { desc = "Pyright check all files" })
			vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostic" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
		end,
	},
}
