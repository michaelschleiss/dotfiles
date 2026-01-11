return {
	"stevearc/conform.nvim",
	lazy = false,
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				tex = { "latexindent" },
				bib = { "bibtex-tidy" },
			},
			formatters = {
				latexindent = {
					command = "latexindent",
					args = { "-m", "-l=" .. vim.fn.expand("~/projects/doktorarbeit/.latexindent.yaml"), "-" },
					stdin = true,
				},
			},
			format_on_save = {
				timeout_ms = 5000,
				lsp_fallback = true,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>gf", function()
			require("conform").format({ async = true, lsp_fallback = true })
		end, { desc = "Conform format" })
	end,
}
