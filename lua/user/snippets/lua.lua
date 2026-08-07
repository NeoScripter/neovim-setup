require("luasnip.session.snippet_collection").clear_snippets("lua")

local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node

local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node

local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("lua", {
	s("fn", fmt("function {} ({})\n\t{} \nend", { i(1), i(2), i(3) })),
	s("if", fmt("if ({}) then\n\t{} \nend\n{}", { i(1), i(2), i(0) })),
	s(
		"test",
		fmt("if ({}) then\n\t{} \nend\n{}", {
			d(1, function()
				local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r")
				return sn(nil, { t(filename) })
			end, { 1 }),

			i(2),
			i(0),
		})
	),
})
