return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "python", "c", "cpp", "markdown", "yaml", "bibtex" },
      auto_install = true,
      highlight = {
        enable = true,
        disable = { "latex" },
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
