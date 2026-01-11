return {
	"jalvesaq/zotcite",
	branch = "pynvim",  -- Required for Neovim < 0.11.5
	pin = true,  -- IMPORTANT: Local patches in lsp.lua - don't update without reapplying
	-- Patches applied to ~/.local/share/nvim/lazy/zotcite/lua/zotcite/lsp.lua:
	--   1. Line ~318: Added 'return' after set_compl_region_rnw() for tex files
	--   2. Line ~219: Added triggerCharacters = { "{" } for auto-completion
	ft = { "markdown", "pandoc", "rmd", "quarto", "vimwiki", "tex", "rnoweb" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("zotcite").setup({
			-- Use Better BibTeX citation keys if you have it installed
			key_type = "better-bibtex",
			-- Explicitly set Zotero database path (full path to zotero.sqlite)
			zotero_sqlite_path = vim.fn.expand("~/Zotero/zotero.sqlite"),
		})
		-- Force config merge (workaround for timing issue)
		local cfg = require("zotcite.config").get_config()
		local opts = require("zotcite").user_opts
		if opts then
			for k, v in pairs(opts) do cfg[k] = v end
		end

		-- Workaround: zotcite's VimEnter autocmd may not fire reliably
		-- Initialize zotero data immediately since we're already in a tex buffer
		vim.schedule(function()
			local zotero = require("zotcite.zotero")
			if zotero.info()["n refs"] == 0 then
				zotero.init()
				require("zotcite.lsp").start()
			end
		end)

		-- :ZbibAll - Scan all thesis .tex files and update zotcite.bib
		vim.api.nvim_create_user_command("ZbibAll", function()
			local root = vim.fn.getcwd()
			local bibfile = nil

			-- Find first \addbibresource in main tex file
			for _, f in ipairs(vim.fn.glob(root .. "/*.tex", false, true)) do
				local lines = vim.fn.readfile(f)
				for _, line in ipairs(lines) do
					local bib = line:match("\\addbibresource{(.-)}")
					if bib then
						bibfile = root .. "/" .. bib
						break
					end
				end
				if bibfile then break end
			end

			if not bibfile then
				vim.notify("No \\addbibresource found", vim.log.levels.ERROR)
				return
			end

			-- Collect all citation keys from thesis .tex files only
			local ckeys = {}
			local files = {}
			-- main file
			for _, f in ipairs(vim.fn.globpath(root, "mainPhD.tex", false, true)) do
				table.insert(files, f)
			end
			-- chapters, frontmatter, appendices
			for _, f in ipairs(vim.fn.globpath(root, "chapters/*.tex", false, true)) do
				table.insert(files, f)
			end
			for _, f in ipairs(vim.fn.globpath(root, "frontmatter/*.tex", false, true)) do
				table.insert(files, f)
			end
			for _, f in ipairs(vim.fn.globpath(root, "appendices/*.tex", false, true)) do
				table.insert(files, f)
			end

			for _, f in ipairs(files) do
				local content = table.concat(vim.fn.readfile(f), "\n")
				for key in content:gmatch("\\%w*cite[^{]*{([^}]+)}") do
					for k in key:gmatch("([^,]+)") do
						k = k:match("^%s*(.-)%s*$") -- trim
						if k and k ~= "" then ckeys[k] = true end
					end
				end
			end

			local keys = vim.tbl_keys(ckeys)
			if #keys == 0 then
				vim.notify("No citations found", vim.log.levels.WARN)
				return
			end

			-- Call zotcite's update_bib
			local zotero = require("zotcite.zotero")
			local kt = require("zotcite.config").get_key_type(vim.api.nvim_get_current_buf())
			zotero.update_bib(keys, bibfile, kt, true)
			vim.notify(string.format("Updated %s with %d citations", bibfile, #keys), vim.log.levels.INFO)
		end, { desc = "Update zotcite.bib with citations from all .tex files" })

		-- Auto-run ZbibAll before VimTeX compilation
		vim.api.nvim_create_autocmd("User", {
			pattern = "VimtexEventCompileStarted",
			callback = function()
				vim.cmd("ZbibAll")
			end,
			desc = "Update zotcite.bib before compilation",
		})
	end,
}
