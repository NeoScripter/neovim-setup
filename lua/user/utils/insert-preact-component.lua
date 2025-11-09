local M = {}

function M.insert_preact_component()
	local api = vim.api

	-- Get file name without extension
	local filename = vim.fn.expand("%:t:r")

	-- Convert kebab-case or snake_case → PascalCase
	local function to_pascal_case(name)
		name = name:gsub("[-_](%w)", function(c)
			return c:upper()
		end)
		return name:sub(1, 1):upper() .. name:sub(2)
	end

	local component_name = to_pascal_case(filename)

	local scaffold = string.format(
		[[
import { FC } from 'preact/compat';

const %s: FC<{ className?: string }> = ({ className }) => {
    return ()
};

export default %s;
]],
		component_name,
		component_name
	)

	api.nvim_put(vim.split(scaffold, "\n"), "l", true, true)
end

return M
