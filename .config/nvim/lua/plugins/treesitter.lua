return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
 	   local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.latex = {
  install_info = {
    url = "https://github.com/latex-lsp/tree-sitter-latex",
    files = { "src/grammar.json" }, -- not strictly necessary, but a fallback
    generate_requires_npm = true, -- needed because it uses grammar.js
    requires_generate_from_grammar = true,
  },
  filetype = "tex",
}

		require("nvim-treesitter.configs").setup({
			ensure_installed = { "lua", "python", "c", "cpp", "markdown", "yaml" },
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-s>",
					node_incremental = "<C-s>",
					node_decremental = "<C-backspace>",
				},
			},
		})
	end,
}
