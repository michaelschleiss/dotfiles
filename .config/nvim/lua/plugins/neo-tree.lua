return
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information

      },
      lazy = false, 
      opts = {
      },
      config = function()
        vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<CR>', {})
        require("neo-tree").setup({
        close_if_last_window = true,
        enable_git_status = true,
        enable_diagnostics = true,
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = true,
            hide_gitignored = true,
          },
          follow_current_file = {
            enabled = true, -- auto-focus on file in the tree
          },
          use_libuv_file_watcher = true, -- 👈 this enables auto-refresh
        },
      })
      end
}
