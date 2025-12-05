return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "python", "c", "cpp", "markdown", "yaml", "latex", "bibtex" },
      auto_install = true,
      highlight = {
        enable = true,
        disable = { "latex" },  -- Let VimTeX handle LaTeX highlighting
      },
      indent = {
        enable = true,
        disable = { "latex" },
      },
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
