require("luasnip.session.snippet_collection").clear_snippets("css")

local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node

local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("css", {
	s("center", fmt("display: flex;\nalign-items: center;\njustify-content: center;\n{}", { i(1) })),
	s("media", fmt("@media ({}-width: {}) {{\n\t{}\n}}", { i(1, "min"), i(2), i(3) })),
})
