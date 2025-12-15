return {
  {
    "hrsh7th/cmp-nvim-lsp",
      dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "kdheepak/cmp-latex-symbols",
  },
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      -- nvim-cmp can blow up if a source returns a Blob/number for fields like
      -- `abbr` or `menu`; coerce anything non-string to a printable string.
      local function to_s(val)
        if type(val) == "string" then return val end
        if val == nil then return "" end
        return tostring(val)
      end
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = function(entry, vim_item)
            -- Show source name in brackets
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              vimtex = "[Cite]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
              latex_symbols = "[LaTeX]",
            })[entry.source.name] or "[" .. entry.source.name .. "]"
            vim_item.abbr = to_s(vim_item.abbr)
            vim_item.menu = to_s(vim_item.menu)
            vim_item.kind = to_s(vim_item.kind)
            return vim_item
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- Keymaps
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- Tab: select next item or jump to next snippet placeholder
          ["<Tab>"] = cmp.mapping(function(fallback)
            local luasnip = require("luasnip")
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Shift-Tab: select prev item or jump to prev snippet placeholder
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            local luasnip = require("luasnip")
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" }, -- For luasnip users.
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- LaTeX-specific completion sources
      -- Note: zotcite provides citations via its own LSP "zotero_ls"
      cmp.setup.filetype({ "tex", "plaintex", "bib" }, {
        sources = cmp.config.sources({
          { name = "nvim_lsp", keyword_length = 0 },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "latex_symbols" },
          { name = "path" },
        }),
      })

      -- Auto-trigger completion after { in tex files (for \cite{, \ref{, etc.)
      vim.api.nvim_create_autocmd("InsertCharPre", {
        pattern = { "*.tex", "*.bib" },
        callback = function()
          if vim.v.char == "{" then
            -- Delay to let cursor position update and zotcite's compl_region check
            vim.defer_fn(function()
              -- Force cursor move event to update zotcite's compl_region
              vim.cmd("doautocmd CursorMovedI")
              cmp.complete()
            end, 50)
          end
        end,
      })
    end,
  }
}
