return {
	"stevearc/conform.nvim",
	lazy = false,
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				-- Python formatting via Ruff (ruff format)
				python = { "ruff_format" },
				tex = { "latexindent" },
				bib = { "bibtex-tidy" },
			},
			format_on_save = {
				timeout_ms = 1000,
				lsp_fallback = true,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>gf", function()
			require("conform").format({ async = true, lsp_fallback = true })
		end, { desc = "Conform format" })
	end,
}
