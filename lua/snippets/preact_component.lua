-- Add this to ~/.config/nvim/lua/snippets/react.lua

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets("lua", {
    s("fn", fmt("function"))
})

-- Register for React/Preact file types
local filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" }

for _, ft in ipairs(filetypes) do
	ls.add_snippets(ft, { preact_component })
end
