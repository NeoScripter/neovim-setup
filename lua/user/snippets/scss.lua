require("luasnip.session.snippet_collection").clear_snippets("scss")

local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node

local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("scss", {
	s("center", fmt("display: flex;\nalign-items: center;\njustify-content: center;\n{}", { i(1) })),
	s("media", fmt("@media ({}-width: {}) {{\n\t{}\n}}", { i(1, "min"), i(2), i(3) })),
	s("mw", fmt("@include u.mw({}) {{\n\t{}\n}}", { i(1, "sm"), i(2) })),
	s("px", fmt("@include u.px({}, {}, {}, {}, {});", { i(1), i(2), i(3), i(4), i(5) })),
	s("rem", fmt("@include u.rem({}, {}, {}, {}, {});", { i(1), i(2), i(3), i(4), i(5) })),
})
