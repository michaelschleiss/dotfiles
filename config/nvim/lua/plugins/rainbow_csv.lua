return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  opts = {
    view = {
      display_mode = "highlight",
      spacing = 1,
    },
    header = {
      lnum = 1,
      sticky = {
        enabled = true,
        separator = "─",
      },
    },
    parser = {
      delimiter = {
        ft = {
          csv = ",",
          tsv = "\t",
        },
        fallbacks = { ",", "\t", ";", "|" },
      },
      comments = { "#", "//" },
    },
    keymaps = {
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
      jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
    },
  },
  config = function(_, opts)
    local csvview = require("csvview")
    csvview.setup(opts)
    -- Auto-enable csvview for CSV files (BufEnter fires after buffer is ready)
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = { "*.csv", "*.tsv", "*.tab" },
      callback = function(args)
        vim.treesitter.stop(args.buf)
        csvview.enable()
      end,
    })
  end,
  init = function()
    vim.filetype.add({
      extension = {
        csv = "csv",
        tsv = "tsv",
        tab = "tsv",
      },
    })
  end,
}

