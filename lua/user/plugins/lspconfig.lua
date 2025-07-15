-- Language Server Protocol

return {
	"neovim/nvim-lspconfig",
	event = "VeryLazy",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"b0o/schemastore.nvim",
		-- { 'nvimtools/none-ls.nvim', dependencies = 'nvim-lua/plenary.nvim' },
		-- 'jayp0521/mason-null-ls.nvim',
	},
	config = function()
		-- Setup Mason to automatically install LSP servers
		require("mason").setup({
			ui = {
				height = 0.8,
			},
		})
		require("mason-lspconfig").setup({
			automatic_installation = false,
			automatic_enable = false,
		})

		-- require("mason-lspconfig").setup_handlers({
		-- 	function(server_name)
		-- 		-- Skip servers you configure manually below
		-- 		local manually_configured = {
		-- 			intelephense = true,
		-- 			volar = true,
		-- 			rust_analyzer = true,
		-- 			ts_ls = true,
		-- 			sqls = true,
		-- 			tailwindcss = true,
		-- 			cssls = true,
		-- 			jsonls = true,
		-- 			lua_ls = true,
		-- 		}

		-- 		if not manually_configured[server_name] then
		-- 			require("lspconfig")[server_name].setup({})
		-- 		end
		-- 	end,
		-- })
		local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

		-- PHP
		require("lspconfig").intelephense.setup({
			cmd = { "intelephense", "--stdio" },
			filetypes = { "php" },
			-- root_markers = { ".git", "composer.json", ".php" },
			root_dir = function(fname)
				return require("lspconfig.util").root_pattern("composer.json", ".git")(fname) or vim.fn.getcwd()
			end,
			commands = {
				IntelephenseIndex = {
					function()
						vim.lsp.buf.execute_command({ command = "intelephense.index.workspace" })
					end,
				},
			},
			on_attach = function(client, bufnr)
				-- client.server_capabilities.documentFormattingProvider = false
				-- client.server_capabilities.documentRangeFormattingProvider = false
				-- if client.server_capabilities.inlayHintProvider then
				--   vim.lsp.buf.inlay_hint(bufnr, true)
				-- end
			end,
			capabilities = capabilities,
			settings = {
				intelephense = {
					environment = {
						includePaths = { "vendor" }, -- explicitly include vendor
					},
					files = {
						maxSize = 5000000, -- 5MB (default is 1MB, might block big files)
					},
					stubs = {
						-- Base PHP stubs (ESSENTIAL)
						"Core",
						"standard",
						"superglobals",
						"date",
						"json",
						"pcre",
						"spl",

						-- Laravel-specific stubs
						"laravel",
						"eloquent",
						"blade",
						"log",
						"view",
						"cache",
						"auth",
						"queue",
						"event",
						"filesystem",
						"http",
						"mail",
						"database",
						"session",
						"testing",
						"support",
						"carbon",
						"phpunit",
					},
				},
			},
		})

		require("lspconfig").volar.setup({
			capabilities = capabilities,
			filetypes = { "vue" },
			init_options = {
				vue = {
					hybridMode = false,
				},
			},
			settings = {
				typescript = {
					inlayHints = {
						enumMemberValues = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
						propertyDeclarationTypes = { enabled = true },
						parameterTypes = {
							enabled = true,
							suppressWhenArgumentMatchesName = true,
						},
						variableTypes = { enabled = true },
					},
				},
			},
		})

		require("lspconfig").rust_analyzer.setup({
			cmd = { "rust-analyzer" },
			filetypes = { "rust" },
			capabilities = vim.tbl_deep_extend("force", capabilities, {
				experimental = {
					serverStatusNotification = true,
				},
			}),
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
					},
					check = {
						command = "clippy",
					},
					diagnostics = {
						enable = true,
					},
				},
			},
			before_init = function(init_params, config)
				if config.settings and config.settings["rust-analyzer"] then
					init_params.initializationOptions = config.settings["rust-analyzer"]
				end
			end,
			on_attach = function(_, bufnr)
				vim.api.nvim_buf_create_user_command(bufnr, "LspCargoReload", function()
					local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "rust_analyzer" })
					for _, client in ipairs(clients) do
						vim.notify("Reloading Cargo workspace")
						client.request("rust-analyzer/reloadWorkspace", nil, function(err)
							if err then
								error(tostring(err))
							end
							vim.notify("Cargo workspace reloaded")
						end, 0)
					end
				end, { desc = "Reload current cargo workspace" })
			end,
			root_dir = function(fname)
				local util = require("lspconfig.util")
				local user_home = vim.fn.expand("$HOME")
				local cargo_home = os.getenv("CARGO_HOME") or user_home .. "/.cargo"
				local rustup_home = os.getenv("RUSTUP_HOME") or user_home .. "/.rustup"

				local function is_library(path)
					local candidates = {
						cargo_home .. "/registry/src",
						cargo_home .. "/git/checkouts",
						rustup_home .. "/toolchains",
					}
					for _, base in ipairs(candidates) do
						if fname:find(vim.fn.expand(base), 1, true) then
							return true
						end
					end
					return false
				end

				if is_library(fname) then
					local clients = vim.lsp.get_clients({ name = "rust_analyzer" })
					return #clients > 0 and clients[#clients].config.root_dir or nil
				end

				local cargo_toml = util.root_pattern("Cargo.toml")(fname)
				if not cargo_toml then
					return util.root_pattern("rust-project.json", ".git")(fname)
				end

				local output = vim.fn.system({
					"cargo",
					"metadata",
					"--no-deps",
					"--format-version",
					"1",
					"--manifest-path",
					cargo_toml .. "/Cargo.toml",
				})

				local decoded = vim.fn.json_decode(output)
				if decoded and decoded.workspace_root then
					return vim.fn.fnamemodify(decoded.workspace_root, ":p")
				end

				return cargo_toml
			end,
		})

		-- TypeScript (tsserver via ts_ls)
		require("lspconfig").ts_ls.setup({
			capabilities = capabilities,
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"vue",
			},
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vim.fn.stdpath("data")
							.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
						languages = { "vue" },
					},
				},
			},
			settings = {
				typescript = {
					tsserver = {
						useSyntaxServer = false,
					},
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		})

		require("lspconfig").sqls.setup({
			cmd = { "sqls" },
			filetypes = { "sql" },
			root_dir = require("lspconfig").util.root_pattern(".git", "config.yml"),
		})
		-- Tailwind CSS
		require("lspconfig").tailwindcss.setup({
			capabilities = capabilities,
			cmd = { "tailwindcss-language-server", "--stdio" },
			filetypes = {
				-- html
				"aspnetcorerazor",
				"astro",
				"astro-markdown",
				"blade",
				"clojure",
				"django-html",
				"htmldjango",
				"edge",
				"eelixir",
				"elixir",
				"ejs",
				"erb",
				"eruby",
				"gohtml",
				"gohtmltmpl",
				"haml",
				"handlebars",
				"hbs",
				"html",
				"htmlangular",
				"html-eex",
				"heex",
				"jade",
				"leaf",
				"liquid",
				"markdown",
				"mdx",
				"mustache",
				"njk",
				"nunjucks",
				"php",
				"razor",
				"slim",
				"twig",
				-- css
				"css",
				"less",
				"postcss",
				"sass",
				"scss",
				"stylus",
				"sugarss",
				-- js
				"javascript",
				"javascriptreact",
				"reason",
				"rescript",
				"typescript",
				"typescriptreact",
				-- mixed
				"vue",
				"svelte",
				"templ",
			},
			settings = {
				tailwindCSS = {
					validate = true,
					lint = {
						cssConflict = "warning",
						invalidApply = "error",
						invalidScreen = "error",
						invalidVariant = "error",
						invalidConfigPath = "error",
						invalidTailwindDirective = "error",
						recommendedVariantOrder = "warning",
					},
					classAttributes = {
						"class",
						"className",
						"class:list",
						"classList",
						"ngClass",
					},
					includeLanguages = {
						eelixir = "html-eex",
						elixir = "phoenix-heex",
						eruby = "erb",
						heex = "phoenix-heex",
						htmlangular = "html",
						templ = "html",
					},
				},
			},
			before_init = function(_, config)
				config.settings = config.settings or {}
				config.settings.editor = config.settings.editor or {}
				config.settings.editor.tabSize = config.settings.editor.tabSize or vim.lsp.util.get_effective_tabstop()
			end,
			workspace_required = false,
			root_dir = function(fname)
				return require("lspconfig.util").root_pattern("package.json")(fname) or vim.fn.getcwd()
			end,
		})

		require("lspconfig").cssls.setup({
			capabilities = capabilities,
			cmd = { "vscode-css-language-server", "--stdio" },
			filetypes = { "css", "scss", "less", "sass" },
			init_options = { provideFormatter = true },
			root_markers = { "package.json", ".git" },
			settings = {
				css = { validate = true },
				scss = { validate = true },
				less = { validate = true },
				sass = { validate = true },
			},
			on_attach = function(client, bufnr)
				local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
				if filetype == "sass" then
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
				end
			end,
		})
		-- JSON
		require("lspconfig").jsonls.setup({
			capabilities = capabilities,
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
				},
			},
		})

		-- Lua
		require("lspconfig").lua_ls.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					workspace = {
						checkThirdParty = false,
						library = {
							"${3rd}/luv/library",
							unpack(vim.api.nvim_get_runtime_file("", true)),
						},
					},
				},
			},
		})

		require("lspconfig").emmet_language_server.setup({
			capabilities = capabilities,
			cmd = { "emmet-language-server", "--stdio" },
			filetypes = {
				"astro",
				"css",
				"eruby",
				"html",
				"html.angular",
				"html.twig",
				"htmldjango",
				"javascriptreact",
				"less",
				"pug",
				"sass",
				"scss",
				"svelte",
				"templ",
				"typescriptreact",
				"vue",
			},
			root_dir = function(fname)
				return require("lspconfig.util").root_pattern(".git")(fname) or vim.fn.getcwd()
			end,
		})

		-- Keymaps
		-- vim.keymap.set("n", "<Leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>")
		vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>")
		vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
		vim.keymap.set("n", "gi", ":Telescope lsp_implementations<CR>")
		vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>")
		vim.keymap.set("n", "<Leader>lr", ":LspRestart<CR>", { silent = true })
		vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
		vim.keymap.set("n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")

		-- Diagnostic configuration
		vim.diagnostic.config({
			virtual_text = true,
			float = {
				source = true,
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.INFO] = "",
					[vim.diagnostic.severity.HINT] = "",
				},
			},
		})
	end,
}
