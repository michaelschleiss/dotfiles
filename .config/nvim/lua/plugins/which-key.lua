return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 1000,
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- VimTeX mappings with descriptions
    wk.add({
      -- Compilation & Viewing
      { "<localleader>l", group = "VimTeX" },
      { "<localleader>ll", desc = "Compile" },
      { "<localleader>lv", desc = "View PDF" },
      { "<localleader>lk", desc = "Stop compilation" },
      { "<localleader>le", desc = "Errors/warnings" },
      { "<localleader>lc", desc = "Clean aux files" },
      { "<localleader>lC", desc = "Clean full" },
      { "<localleader>lt", desc = "TOC toggle" },
      { "<localleader>li", desc = "Info" },
      { "<localleader>lI", desc = "Info full" },
      { "<localleader>lg", desc = "Status" },
      { "<localleader>lG", desc = "Status all" },
      { "<localleader>lq", desc = "Log" },
      { "<localleader>lo", desc = "Compile output" },
      { "<localleader>la", desc = "Context menu" },
      { "<localleader>lm", desc = "Imaps list" },
      { "<localleader>lx", desc = "Reload" },
      { "<localleader>ls", desc = "Toggle main" },

      -- Navigation (these are VimTeX buffer-local mappings)
      { "]", group = "Next" },
      { "[", group = "Previous" },
      { "]]", desc = "Next section" },
      { "[[", desc = "Previous section" },
      { "]m", desc = "Next \\begin" },
      { "[m", desc = "Previous \\begin" },
      { "]M", desc = "Next \\end" },
      { "[M", desc = "Previous \\end" },
      { "]/", desc = "Next comment" },
      { "[/", desc = "Previous comment" },
      { "]r", desc = "Next frame \\begin" },
      { "[r", desc = "Previous frame \\begin" },
      { "]R", desc = "Next frame \\end" },
      { "[R", desc = "Previous frame \\end" },

      -- Toggles & Actions
      { "ts", group = "Toggle surrounding" },
      { "tse", desc = "Toggle env star (equation ↔ equation*)" },
      { "tsd", desc = "Toggle delimiter (( ↔ \\left()" },
      { "tsD", desc = "Toggle delimiter (reversed)" },
      { "tsc", desc = "Toggle command star" },
      { "tsf", desc = "Toggle fraction" },

      { "cs", group = "Change surrounding" },
      { "cse", desc = "Change environment" },
      { "csc", desc = "Change command" },
      { "cs$", desc = "Change math delimiter" },

      { "ds", group = "Delete surrounding" },
      { "dse", desc = "Delete environment" },
      { "dsc", desc = "Delete command" },
      { "ds$", desc = "Delete math delimiter" },

      -- Text Objects (operator-pending & visual)
      { "ie", desc = "Inner environment", mode = { "o", "x" } },
      { "ae", desc = "Around environment", mode = { "o", "x" } },
      { "i$", desc = "Inner math", mode = { "o", "x" } },
      { "a$", desc = "Around math", mode = { "o", "x" } },
      { "id", desc = "Inner delimiter", mode = { "o", "x" } },
      { "ad", desc = "Around delimiter", mode = { "o", "x" } },
      { "ic", desc = "Inner command", mode = { "o", "x" } },
      { "ac", desc = "Around command", mode = { "o", "x" } },
      { "iP", desc = "Inner section", mode = { "o", "x" } },
      { "aP", desc = "Around section", mode = { "o", "x" } },
    })
  end,
}
