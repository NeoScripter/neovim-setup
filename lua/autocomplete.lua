local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),

    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "emmet" },
        { name = "buffer" },
        { name = "path" },
    }),

    sorting = {
        comparators = {
            -- ⬇ Push LSP snippets (CompletionItemKind.Snippet) lower
            function(entry1, entry2)
                local snippetKind = cmp.lsp.CompletionItemKind.Snippet
                local kind1 = entry1:get_kind()
                local kind2 = entry2:get_kind()

                if kind1 == snippetKind and kind2 ~= snippetKind then
                    return false
                elseif kind2 == snippetKind and kind1 ~= snippetKind then
                    return true
                end
            end,

            -- ⬇ Optionally push Emmet below normal completions too
            function(entry1, entry2)
                if entry1.source.name == "emmet" and entry2.source.name ~= "emmet" then
                    return false
                elseif entry2.source.name == "emmet" and entry1.source.name ~= "emmet" then
                    return true
                end
            end,

            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
})
