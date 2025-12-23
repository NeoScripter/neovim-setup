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
		[[import { NodeProps } from '@/types/nodeProps';
import { FC } from 'preact/compat';

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
