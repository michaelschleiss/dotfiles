if vim.g.vscode then
  -- VSCode Neovim
  require "user.vscode_keymaps"
else
  -- ordinary nvim

  require("vim-options")
  -- lazy needs to be configured after map leader and opts
  require("config.lazy")
end
