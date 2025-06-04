return {
    'mfussenegger/nvim-lint',
    config = function()
        require('lint').linters_by_ft = {
            javascript = { 'eslint_d' },
            javascriptreact = { 'eslint_d' },
            typescript = { 'eslint_d' },
            typescriptreact = { 'eslint_d' },
            php = { 'phpstan' },
            html = { 'djlint' },         -- or another linter if preferred
            vue = { 'eslint_d' },        -- works if ESLint is configured for Vue
            css = { 'stylelint' },
            scss = { 'stylelint' },
        }

        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function()
                require("lint").try_lint()
            end,
        })
    end,
}
