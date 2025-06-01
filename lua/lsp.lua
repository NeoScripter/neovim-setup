require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "ts_ls",
        "html",
        "emmet_ls",
        "cssls",
        "jsonls",
        "eslint",
        "lua_ls",
        "tailwindcss",
        "intelephense",
    },
})

local lspconfig = require("lspconfig")


lspconfig.emmet_ls.setup({
    filetypes = {
        "html",
        "css",
        "scss",
        "sass",
        "javascript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "blade", -- Laravel Blade templates
        "php",   -- for HTML in PHP templates
    },
    init_options = {
        html = {
            options = {
                ["bem.enabled"] = true,
            },
        },
        css = {
            options = {
                ["bem.enabled"] = true,
            },
        },
        javascript = {
            options = {
                ["bem.enabled"] = true,
            },
        },
        jsx = {
            options = {
                ["bem.enabled"] = true,
            },
        },
        -- universal config
        snippets = {},
        showExpandedAbbreviation = "always",
        showAbbreviationSuggestions = true,
        syntaxProfiles = {
            html = "xhtml", -- or "html"
            vue = "html",
            javascript = "jsx",
            blade = "html",
        },
        variables = {
            lang = "en",
        },
        excludeLanguages = {},
    },
})

lspconfig.tailwindcss.setup({
    filetypes = {
        "html",
        "blade",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
    },
    init_options = {
        userLanguages = {
            javascript = "html",
            typescript = "html",
            javascriptreact = "html",
            typescriptreact = "html",
        },
    },
})

lspconfig.vuels.setup({
    filetypes = { 'vue', 'javascript', 'typescript' },
    settings = {
        vetur = {
            completion = {
                autoImport = true,
                tagCasing = "kebab",
                useScaffoldSnippets = true,
            },
            format = {
                enable = true,
                options = {
                    tabSize = 4,
                    useTabs = false,
                },
            },
            validation = {
                template = true,
                script = true,
                style = true,
            },
        },
        typescript = {
            inlayHints = {
                enumMemberValues = {
                    enabled = true,
                },
                functionLikeReturnTypes = {
                    enabled = true,
                },
                propertyDeclarationTypes = {
                    enabled = true,
                },
                parameterTypes = {
                    enabled = true,
                    suppressWhenArgumentMatchesName = true,
                },
                variableTypes = {
                    enabled = true,
                },
            },
        },
    },
})

lspconfig.ts_ls.setup({
    filetypes = { 'javascript', 'typescript' },
    settings = {
        typescript = {
            tsserver = {
                useSyntaxServer = false,
            },
            inlayHints = {
                includeInlayParameterNameHints = 'all',
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

local servers = {
    "html",
    "cssls",
    "jsonls",
    "eslint",
    "lua_ls",
    "tailwindcss",
    "intelephense",
}
for _, server in ipairs(servers) do
    lspconfig[server].setup({})
end
