return {
  "lervag/vimtex",
  lazy = false,     -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 0
    -- Use LuaLaTeX (no write stream limit, better Unicode support)
    vim.g.vimtex_compiler_latexmk_engines = { _ = "-lualatex" }
    vim.g.vimtex_compiler_latexmk = {
      continuous = 1,
      out_dir = "build",
      options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-shell-escape",
      },
    }
  end,
  config = function()
    -- Write server name for inverse search (Skim → Neovim)
    -- Disable treesitter highlighting for tex files
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'tex',
      callback = function()
        vim.treesitter.stop()  -- Force disable treesitter for this buffer
        local file = io.open('/tmp/vimtexserver.txt', 'w')
        if file then
          file:write(vim.v.servername)
          file:close()
        end
      end
    })
  end
}
