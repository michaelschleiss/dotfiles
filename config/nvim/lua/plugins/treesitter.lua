-- nvim-treesitter "main" (Neovim >= 0.12): installs parsers and queries only.
-- Highlighting, indent and node selection are wired up here instead of via
-- the old configs.setup() modules. LaTeX is left to VimTeX.
local ensure_installed = { "lua", "python", "c", "cpp", "markdown", "markdown_inline", "yaml", "bibtex" }
local skip = { tex = true, latex = true }

-- Visually select the node under the cursor (like the old init_selection).
local function select_node()
  local parser = vim.treesitter.get_parser(nil, nil, { error = false })
  if not parser then
    return
  end
  parser:parse(true) -- 0.12 parses asynchronously; get_node() needs a current tree
  local node = vim.treesitter.get_node()
  if not node then
    return
  end
  local sr, sc, er, ec = node:range()
  if ec == 0 and er > sr then -- range ends at column 0 of the next line
    er = er - 1
    ec = #vim.fn.getline(er + 1) + 1
  end
  -- Set the marks and reselect: ':normal! v' would end Visual mode on return.
  -- 'gv' needs a previous charwise selection, so make one first if missing.
  if vim.fn.visualmode() ~= "v" then
    vim.cmd("normal! v\27")
  end
  vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
  vim.fn.setpos("'>", { 0, er + 1, math.max(ec, 1), 0 })
  vim.cmd("normal! gv")
end

local function attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
    return
  end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    ts.install(ensure_installed)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang or skip[lang] then
          return
        end
        if vim.treesitter.language.add(lang) then
          attach(args.buf, lang)
        elseif vim.tbl_contains(ts.get_available(), lang) then
          -- Same as the old auto_install: fetch the missing parser, then attach.
          ts.install(lang):await(function(err)
            if not err then
              vim.schedule(function() attach(args.buf, lang) end)
            end
          end)
        end
      end,
    })

    -- Incremental selection (built into Neovim 0.12; visual `an`/`in` work too).
    vim.keymap.set("n", "<C-s>", select_node, { desc = "Select treesitter node" })
    vim.keymap.set("x", "<C-s>", function() vim.treesitter.select("parent") end, { desc = "Expand selection to parent node" })
    vim.keymap.set("x", "<C-backspace>", function() vim.treesitter.select("child") end, { desc = "Shrink selection to child node" })
  end,
}
