return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  lazy = false,
  opts = {},
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
        use_libuv_file_watcher = true, -- auto-refresh
        window = {
          mappings = {
            ["o"] = "system_open",
          },
        },
      },
      commands = {
        system_open = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()

          local sysname = vim.loop.os_uname().sysname
          local is_wsl = (vim.fn.has("wsl") == 1)

          local opener
          if sysname == "Darwin" and vim.fn.executable("open") == 1 then
            opener = { "open", path }
          elseif is_wsl and vim.fn.executable("wslview") == 1 then
            opener = { "wslview", path }
          elseif vim.fn.executable("xdg-open") == 1 then
            opener = { "xdg-open", path }
          else
            vim.notify(
              "No suitable opener found. Install one of: 'open' (macOS), 'xdg-open' (Linux), or 'wslview' (WSL).",
              vim.log.levels.ERROR
            )
            return
          end

          vim.fn.jobstart(opener, { detach = true })
        end,
      },
    })
  end,
}
