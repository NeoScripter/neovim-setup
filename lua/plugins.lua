return {
    { "folke/lazy.nvim" },

    -- LSP and Mason
    { "neovim/nvim-lspconfig" },
    { "hoffs/omnisharp-extended-lsp.nvim" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "jay-babu/mason-null-ls.nvim" },
    { "nvimtools/none-ls.nvim" },
    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },
    { "saadparwaiz1/cmp_luasnip" },

    -- Syntax Highlighting (Treesitter)
    { "nvim-treesitter/nvim-treesitter",  build = ":TSUpdate" },

    -- File Explorer
    { "nvim-tree/nvim-tree.lua" },

    -- Fuzzy Finder
    { "nvim-telescope/telescope.nvim",    requires = { "nvim-lua/plenary.nvim" } },
    {
        "nvim-telescope/telescope-project.nvim",
        config = function()
            require("telescope").load_extension("project")
        end,
    },
    {
        "folke/trouble.nvim",
        opts = { use_diagnostic_signs = true },
    },
    -- Status Line
    { "nvim-lualine/lualine.nvim" },

    -- Git Integration
    { "lewis6991/gitsigns.nvim" },

    -- Auto Pairs
    { "windwp/nvim-autopairs" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    -- Commenting Utility
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            require("Comment").setup({
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
    },
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        event = "VeryLazy",
    },
    -- Colorscheme
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000, -- load before others
        config = function()
            require("nightfox").setup({
                options = {
                    transparent = false,
                    terminal_colors = true,
                    dim_inactive = false,
                    styles = {
                        comments = "italic",
                        keywords = "bold",
                        types = "italic,bold",
                    },
                },
            })

            -- Load your preferred theme from the Nightfox family
            vim.cmd("colorscheme duskfox")
        end,
    },
    { "nvim-tree/nvim-tree.lua" },

    { "ThePrimeagen/harpoon",   branch = "harpoon2", dependencies = { "nvim-lua/plenary.nvim" } },
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                direction = "horizontal", -- or "float", "vertical"
                size = 15,
                open_mapping = [[<C-\>]], -- Key to toggle terminal
                start_in_insert = true,
                persist_size = true,
                shade_terminals = true,
            })
        end,
    },
    {
        "kylechui/nvim-surround",
        version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    },
    -- {
    --     "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    --     event = "LspAttach",
    --     config = function()
    --         require("lsp_lines").setup()
    --
    --         vim.diagnostic.config({
    --             virtual_text = false,
    --             virtual_lines = true,
    --             signs = true,
    --             underline = true,
    --             update_in_insert = false,
    --             severity_sort = true,
    --         })
    --
    --         vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    --             vim.lsp.handlers.hover,
    --             {
    --                 border = "rounded",
    --                 max_width = 80,
    --                 wrap = true,
    --             }
    --         )
    --
    --         vim.keymap.set(
    --             "",
    --             "<Leader>l",
    --             require("lsp_lines").toggle,
    --             { desc = "Toggle lsp_lines" }
    --         )
    --     end,
    -- }

}
