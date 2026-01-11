return {
  "rebelot/kanagawa.nvim",
	config = function()
    require('kanagawa').setup({
      compile=false,
      transparent=false,
    });
		vim.cmd("colorscheme kanagawa");
	end,
}
