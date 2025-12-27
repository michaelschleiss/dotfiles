return {
	"barreiroleo/ltex_extra.nvim",
	-- TODO: switch to main branch once dev is merged (fixes nvim 0.11 compatibility)
	branch = "dev",
	ft = { "tex", "bib", "markdown" },
	opts = {
		load_langs = { "en-US", "de-DE" },
		path = vim.fn.stdpath("data") .. "/ltex",
	},
}
