-- Fuzzy finder

return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-live-grep-args.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
		},
	},
	keys = {
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files()
			end,
		},
		{
			"<leader>fF",
			function()
				require("telescope.builtin").find_files({ no_ignore = true, prompt_title = "All Files" })
			end,
		},
		{
			"<leader>fb",
			function()
				require("telescope.builtin").buffers()
			end,
		},
		{
			"<leader>fg",
			function()
				require("telescope").extensions.live_grep_args.live_grep_args({
					prompt_title = "Grep Project",
					vimgrep_arguments = {
						"rg",
						"-L",
						"--color=never",
						"--sort=path",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
				})
			end,
		},
		{
			"<leader>G",
			function()
				require("telescope").extensions.live_grep_args.live_grep_args({
					prompt_title = "Grep All Files",
					vimgrep_arguments = {
						"rg",
						"--hidden",
						"--no-ignore",
						"-L",
						"--color=never",
						"--sort=path",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
				})
			end,
		},
		{
			"<leader>h",
			function()
				require("telescope.builtin").help_tags()
			end,
		},
		{
			"<leader>s",
			function()
				require("telescope.builtin").lsp_document_symbols()
			end,
		},
		{
			"<leader>fp",
			function()
				local scan = require("plenary.scandir")
				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local conf = require("telescope.config").values
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")

				local dirs = {}
				local bases = {
					"d:/herd",
					"d:/javascript",
					"c:/users/user/appdata/local",
				}

				for _, base in ipairs(bases) do
					local ok, results = pcall(scan.scan_dir, base, { only_dirs = true, depth = 2 })
					if ok then
						vim.list_extend(dirs, results)
					end
				end

				pickers
					.new({}, {
						prompt_title = "select project",
						finder = finders.new_table({ results = dirs }),
						sorter = conf.generic_sorter({}),
						attach_mappings = function(prompt_bufnr, _)
							actions.select_default:replace(function()
								local selection = action_state.get_selected_entry()
								actions.close(prompt_bufnr)
								local path = selection[1]
								vim.cmd("cd " .. vim.fn.fnameescape(path))
								vim.notify("project root: " .. path)
								require("telescope.builtin").find_files({ cwd = path })
							end)
							return true
						end,
					})
					:find()
			end,
		},
	},
	config = function()
		local actions = require("telescope.actions")

		require("telescope").setup({
			defaults = {
				path_display = { truncate = 1 },
				prompt_prefix = "   ",
				selection_caret = "  ",
				layout_config = {
					prompt_position = "bottom",
				},
				preview = {
					filesize_limit = 1,
					timeout = 200,
					msg_bg_fillchar = " ",
				},
				sorting_strategy = "descending",
				mappings = {
					i = {
						["<esc>"] = actions.close,
						["<C-Down>"] = actions.cycle_history_next,
						["<C-Up>"] = actions.cycle_history_prev,
					},
				},
				file_ignore_patterns = { ".git/" },
			},
			extensions = {
				live_grep_args = {
					mappings = {
						i = {
							["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
							["<C-space>"] = actions.to_fuzzy_refine,
						},
					},
				},
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
			pickers = {
				find_files = {
					hidden = false,
				},
				buffers = {
					previewer = false,
					layout_config = {
						width = 80,
					},
				},
				oldfiles = {
					prompt_title = "History",
				},
				lsp_references = {
					previewer = false,
				},
				lsp_definitions = {
					previewer = false,
				},
				lsp_document_symbols = {
					symbol_width = 55,
				},
			},
		})

		require("telescope").load_extension("fzf")
		require("telescope").load_extension("ui-select")
	end,
}
