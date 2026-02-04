local M = {}

function M.insert_react_component()
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
		[[import { FC } from 'react';
import { NodeProps } from '@/types/ui';

const %s: FC<NodeProps> = ({ className }) => {
    return ()
};

export default %s;
]],
		component_name,
		component_name
	)

	api.nvim_buf_set_lines(0, 0, 0, false, vim.split(scaffold, "\n"))
end

return M
