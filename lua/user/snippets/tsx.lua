require("luasnip.session.snippet_collection").clear_snippets("typescriptreact")

local ls = require("luasnip")

local s = ls.snippet
local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local t = ls.text_node
local rep = require("luasnip.extras").rep

local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("typescriptreact", {
	s(
		"ust",
		fmt("const [{}, set{}] = useState{}({});", {
			i(1),
			d(2, function(args)
				local cap = (args[1][1] or ""):gsub("^%l", string.upper)
				return sn(nil, { t(cap) })
			end, { 1 }),
			i(4),
			i(3),
		})
	),
	s(
		"uef",
		fmt("useEffect(() => {{\n\t{}\n\n\treturn () => {{\n\t\t{}\n\t}};\n}}, [{}]);{}", {
			i(1),
			i(2),
			i(3),
			i(0),
		})
	),
	s(
		"rcmp",
		fmt(
			"import {{ FC }} from 'react';\n\nconst {}: FC<{}> = ({{ {} }}) => {{\n\treturn ({});\n}};\n\nexport default {};",
			{ i(1, "ComponentName"), i(2, "NodeProps"), i(3, "className"), i(4, "<></>"), rep(1) }
		)
	),
	s(
		"prcmp",
		fmt(
			"import {{ FC }} from 'preact/compat';\n\nconst {}: FC<{}> = ({{ {} }}) => {{\n\treturn ({});\n}};\n\nexport default {};",
			{ i(1, "ComponentName"), i(2, "NodeProps"), i(3, "className"), i(4, "<></>"), rep(1) }
		)
	),
})
