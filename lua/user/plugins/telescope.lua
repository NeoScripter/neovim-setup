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
			"<leader>sf",
			function()
				require("telescope.builtin").find_files({
					prompt_title = "Search Files",
				})
			end,
		},
		{
			"<leader>sk",
			function()
				require("telescope.builtin").find_files({
					prompt_title = "Search Keymaps",
				})
			end,
		},
		{
			"<leader>sb",
			function()
				require("telescope.builtin").buffers({
					prompt_title = "Search Buffers",
				})
			end,
		},
		{
			"<leader>sg",
			function()
				require("telescope").extensions.live_grep_args.live_grep_args({
					prompt_title = "Search Grep",
					vimgrep_arguments = {
						"rg",
						"-L",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--glob=!docs/**",
						"--glob=!.docs/**",
						"--glob=!target/**",
						"--glob=!.target/**",
					},
				})
			end,
		},
		{
			"<leader>sh",
			function()
				require("telescope.builtin").help_tags({
					prompt_title = "Search Help",
				})
			end,
		},
		{
			"<leader>ss",
			function()
				require("telescope.builtin").lsp_document_symbols({
					prompt_title = "Search Document Sympbols",
				})
			end,
		},
		{
			"<leader>sw",
			function()
				require("telescope.builtin").grep_string({
					prompt_title = "Search Current Word",
				})
			end,
		},
		{
			"<leader>sd",
			function()
				require("telescope.builtin").diagnostics({
					prompt_title = "Search Diagnostics",
				})
			end,
		},
		{
			"<leader>s.",
			function()
				require("telescope.builtin").oldfiles({
					prompt_title = "Search Recent Files",
				})
			end,
		},
		{
			"<leader>/",
			function()
				require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end,
		},
		{
			"<leader>sn",
			function()
				require("telescope.builtin").find_files({
					cwd = vim.fn.stdpath("config"),
				})
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
						["<C-y>"] = actions.select_default,
                        ["<C-n>"] = actions.move_selection_previous,
                        ["<C-p>"] = actions.move_selection_next,
					},
					n = {
						["<C-y>"] = actions.select_default,
					},
				},
				file_ignore_patterns = {
					"node_modules",
					".git/",
					".docs/",
					".dist/",
					".target/",
					"target/",
					"vendor",
				},
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
