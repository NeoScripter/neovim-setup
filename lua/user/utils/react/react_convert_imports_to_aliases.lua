local M = {}

-- import type { ComponentProps } from 'preact/compat';
-- import useSendMessage from '../../hooks/useSendMessage';
-- import type { CompleteChatInfo } from '../../lib/formatters';
-- import { type SendMessageBlock } from '../../services/api/chats';
-- import ChatTextarea from '../form/ChatTextarea';
-- import ChatFileUploader from '../partials/ChatFileUploader';
--

function M.run()
	local buffer_id = vim.api.nvim_get_current_buf()
	local buffer_lines = vim.api.nvim_buf_get_lines(buffer_id, 0, -1, false)
	local path_pattern = "%.%./[%.%./a-zA-Z0-9]+"

	local alias = "src"

	local current_file_path = vim.api.nvim_buf_get_name(buffer_id)

	for line_num, raw_line in pairs(buffer_lines) do

		if raw_line:find(path_pattern) then
			local matched_path = raw_line:match(path_pattern)
			local resolved_path = vim.fn.fnamemodify(current_file_path, ":h") .. "/" .. matched_path

			local redundant_segments_pattern = "/+[a-zA-Z0-9]+/+%.%./+"

			while resolved_path:find(redundant_segments_pattern) do
				resolved_path = resolved_path:gsub(redundant_segments_pattern, "/")
			end

			local alias_import_path = resolved_path:gsub(".*" .. alias, "@")

			local modified_line = raw_line:gsub("[\"']%.%./.*[\"']", '"' .. alias_import_path .. '"')

			vim.api.nvim_buf_set_lines(buffer_id, line_num - 1, line_num, false, { modified_line })
		end
	end
end

return M
