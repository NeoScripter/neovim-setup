local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Function to convert filename to PascalCase component name
local function get_component_name()
	local filename = vim.fn.expand("%:t:r")
	-- Convert kebab-case or snake_case → PascalCase
	local name = filename:gsub("[-_](%w)", function(c)
		return c:upper()
	end)
	return name:sub(1, 1):upper() .. name:sub(2)
end

-- React component scaffold snippet
local react_component = s({
	trig = "newreactcomponent",
	dscr = "React Functional Component scaffold",
	wordTrig = true,
	priority = 1000,
}, {
	t("import { FC } from 'react';"),
	t({ "", "import { NodeProps } from '@/types/nodeProps';", "", "" }),
	t("const "),
	f(get_component_name, {}),
	t({ ": FC<NodeProps> = ({ className }) => {", "    return (" }),
	i(1),
	t({ "", "    );", "};", "", "" }),
	t("export default "),
	f(get_component_name, {}),
	t(";"),
})

-- Register for React file types
local filetypes = { "typescriptreact", "javascriptreact", "typescript", "javascript" }
for _, ft in ipairs(filetypes) do
	ls.add_snippets(ft, { react_component })
end
