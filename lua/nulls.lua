local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.prettier.with({
            extra_filetypes = { "vue", "blade" },
            extra_args = {
                "--tab-width", "4",
                "--print-width", "80",
                "--single-quote", "true",
                "--bracket-same-line", "false",
                "--trailing-comma", "es5",
                "--html-whitespace-sensitivity", "ignore",
                "--prose-wrap", "never",
            },
        }),
        null_ls.builtins.formatting.phpcbf,
        null_ls.builtins.formatting.blade_formatter.with({
            extra_args = {
                "--wrap-attributes", "force-aligned",
                "--end-with-newline",
                "--sort-tailwindcss-classes",
            },
        }),
        null_ls.builtins.diagnostics.codespell,
    },
})
