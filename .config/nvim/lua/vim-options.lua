  -- Line numbering and scrolling
  vim.opt.number = true        	-- line numbers
  vim.opt.relativenumber = true	-- relative numbering
  vim.opt.scrolloff = 8        	-- scroll offset
  -- Tabs and indentation
  vim.opt.tabstop = 2           -- number of visual spaces per TAB
  vim.opt.softtabstop = 2       -- number of spaces in tab when editing
  vim.opt.shiftwidth = 2        -- number of spaces to use for autoindent
  vim.opt.expandtab = true      -- convert tabs to spaces
  vim.opt.smartindent = true    -- smart indentation when starting new lines
  -- Syntax Highlighting and coloring
  vim.cmd('syntax on')         	-- enable syntax highlighting
  -- views can only be fully collapsed with the global statusline
  vim.opt.laststatus = 3
  -- Key Remaps
  vim.g.mapleader = " "
  vim.keymap.set("n", "<leader><CR>", ":so ~/.config/nvim/init.lua<CR>")
  -- window splitting
  vim.opt.splitright = true
  vim.opt.splitbelow = true

  vim.opt.signcolumn = 'yes'

    
