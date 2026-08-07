require("luasnip.session.snippet_collection").clear_snippets("typescript")

local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node

local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("typescript", {
	s("edfn", fmt("export default function {} ({}) {{\n\t{}\n}}", { i(1, "functionName"), i(2, ""), i(0) })),
	s("fn", fmt("function {} ({}) {{\n\t{}\n}}", { i(1, "functionName"), i(2, ""), i(0) })),
	s("afn", fmt("const {} = ({}) => {{\n\t{}\n}}", { i(1, "functionName"), i(2, ""), i(0) })),
	s("aev", fmt("addEventListener('{}', ({}) => {{\n\t{}\n}})", { i(1, "click"), i(2, "e"), i(0) })),
	s("log", fmt("console.log({})", { i(1) })),
})
