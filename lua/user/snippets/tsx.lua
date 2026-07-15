require("luasnip.session.snippet_collection").clear_snippets("typescriptreact")

local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node

local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("typescriptreact", {
	s(
		"ust",
		fmt("const [{}, set{}] = useState{}({});", {
			i(1),
			d(2, function(args)
				local name = args[1][1] or ""
				local capitalized = name:sub(1, 1):upper() .. name:sub(2)
				return sn(nil, { t(capitalized) })
			end, { 1 }),
			i(4),
			i(3),
		})
	),
})
