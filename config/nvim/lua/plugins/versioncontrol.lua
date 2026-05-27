return {
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()

			vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", {})
			vim.keymap.set("n", "]c", "<cmd>Gitsigns next_hunk<CR>", {})
			vim.keymap.set("n", "[c", "<cmd>Gitsigns prev_hunk<CR>", {})
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	{
		"sindrets/diffview.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
			"DiffviewFileHistory",
		},
		keys = {
			{
				"<leader>gd",
				"<cmd>DiffviewOpen origin/dev...HEAD --imply-local<cr>",
				desc = "Diffview origin/dev...HEAD",
			},
			{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
		},
		opts = {
			file_panel = {
				listing_style = "tree",
				win_config = {
					position = "left",
					width = 40,
				},
			},
			view = {
				default = {
					layout = "diff2_horizontal",
				},
			},
		},
	},
}
