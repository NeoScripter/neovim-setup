local M = {}

local function split(s, sep)
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	s:gsub(pattern, function(c)
		fields[#fields + 1] = c
	end)
	return fields
end

local function move_image_from_downloads_dir()
	local line = vim.api.nvim_get_current_line()
	local _, col = unpack(vim.api.nvim_win_get_cursor(0))
	local i = col + 2
	local j = col + 1
	-- scan left
	while i > 1 and not line:sub(i - 1, i - 1):match("['\"]") do
		i = i - 1
	end
	if not line:sub(i - 1, i - 1):match("['\"]") then
		print("No delimeter found on the line")
		return nil, nil, nil
	end
	-- scan right
	while j <= #line and not line:sub(j, j):match("['\"]") do
		j = j + 1
	end
	if not line:sub(j, j):match("['\"]") then
		print("No delimeter found on the line")
		return nil, nil, nil
	end
	local path = line:sub(i, j - 1)
	if path == "" then
		return nil, nil, nil
	end
	path = path:gsub("@", "/resources/js")
	local fullpath = vim.fn.getcwd() .. path
	local image_name = fullpath:match("([^/]+)$")
	local path_name = fullpath:match("(.+)/[^/]+$")
	local down_dir = "/home/ilya/Downloads/"
	local base_name = image_name:match("(.+)%..+$") or image_name

	-- Find matching file in Downloads
	local extensions = { "png", "jpg", "jpeg", "webp" }
	local found_file = nil
	for _, ext in ipairs(extensions) do
		local test_path = down_dir .. base_name .. "." .. ext
		if vim.fn.filereadable(test_path) == 1 then
			found_file = test_path
			break
		end
	end

	if found_file then
		-- Create directory if it doesn't exist
		vim.fn.mkdir(path_name, "p")
		-- Move the file
		local dest_path = path_name .. "/" .. vim.fn.fnamemodify(found_file, ":t")
		local success = vim.fn.rename(found_file, dest_path)
		if success == 0 then
			print("Moved: " .. found_file .. " -> " .. dest_path)
			return path_name, dest_path, base_name
		else
			print("Error moving file")
			return nil, nil, nil
		end
	else
		print("No matching image found in Downloads")
		return nil, nil, nil
	end
end

local function get_suffix(index, total)
	if index == 1 then
		return "-dk"
	elseif index == total then
		return "-tiny"
	elseif index == 2 then
		return "-tb"
	elseif index == 3 then
		return "-mb"
	else
		return "-" .. index
	end
end

-- Helper function to escape pattern characters
local function vim_patt_escape(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

local function process_image_async(input_path, output_path, width, callback)
	local temp_png = output_path:gsub("%.webp$", ".png")

	-- Chain of commands to run
	local commands = {
		-- Resize to target width and save as PNG
		string.format("convert '%s' -resize '%sx>' '%s'", input_path, width, temp_png),
		-- Optimize PNG
		string.format("optipng -o7 -strip all '%s'", temp_png),
		-- Convert to WebP
		string.format("convert '%s' -quality 75 '%s'", temp_png, output_path),
		-- Delete intermediate PNG
		string.format("rm '%s'", temp_png),
	}

	local full_command = table.concat(commands, " && ")

	-- Run asynchronously
	vim.fn.jobstart(full_command, {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				callback(true, output_path)
			else
				callback(false, "Failed to process image: " .. output_path)
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
	})
end

local function process_all_images(source_path, base_name, path_name, sizes, suffixes, bufnr, line_num)
	local total = #sizes
	local completed = 0
	local new_paths = {}
	local has_error = false

	print(string.format("Processing %d images...", total))

	for i, size in ipairs(sizes) do
		local suffix = suffixes[i]
		local output_name = base_name .. suffix .. ".webp"
		local output_path = path_name .. "/" .. output_name

		process_image_async(source_path, output_path, size, function(success, result)
			completed = completed + 1

			if success then
				table.insert(new_paths, result)
				print(string.format("✓ Completed %d/%d: %s", completed, total, output_name))
			else
				has_error = true
				print("✗ Error: " .. result)
			end

			-- All images processed
			if completed == total then
				if not has_error then
					-- Sort paths to maintain order
					table.sort(new_paths)

					-- Delete original image
					vim.fn.delete(source_path)

					-- Replace the line with new imports
					vim.schedule(function()
						-- Check if buffer still exists
						if not vim.api.nvim_buf_is_valid(bufnr) then
							print("✗ Error: Original buffer no longer exists")
							return
						end

						-- Check if mark still exists and get its position
						local mark_pos = vim.api.nvim_buf_get_mark(bufnr, "I")
						if not mark_pos or mark_pos[1] == 0 then
							print("✗ Error: Could not find original line position")
							return
						end

						local current_line = mark_pos[1]

						local import_lines = {}
						local cwd = vim.fn.getcwd()

						for _, full_path in ipairs(new_paths) do
							local rel_path = full_path:gsub("^" .. vim_patt_escape(cwd), ""):gsub("^/resources/js", "@")
							local var_name_base = base_name:gsub("[-_](%a)", function(c)
								return c:upper()
							end)

							local suffix_part = full_path:match(vim_patt_escape(base_name) .. "%-(.+)%.webp$")

							local var_suffix = ""

							if suffix_part then
								-- Convert suffix from kebab-case to PascalCase (e.g., "tb-tiny" -> "TbTiny")
								var_suffix = suffix_part
									:gsub("^(%a)", function(c)
										return c:upper()
									end)
									:gsub("%-(%a)", function(c)
										return c:upper()
									end)
							else
								print("⚠ Warning: Could not extract suffix from: " .. full_path)
							end

							local var_name = (var_name_base:sub(1, 1):upper() .. var_name_base:sub(2)) .. var_suffix
							local import_line = string.format('import %s from "%s";', var_name, rel_path)
							table.insert(import_lines, import_line)
						end

						-- Replace the line where the mark is
						vim.api.nvim_buf_set_lines(bufnr, current_line - 1, current_line, false, import_lines)

						-- Delete the mark
						vim.api.nvim_buf_del_mark(bufnr, "I")

						print(string.format("\n✓ All images processed! Created %d variants.", total))
					end)
				else
					print("\n✗ Processing completed with errors.")
				end
			end
		end)
	end
end

function M.optimize_image()
	-- Capture buffer and line info immediately
	local bufnr = vim.api.nvim_get_current_buf()
	local line_num = vim.api.nvim_win_get_cursor(0)[1]

	-- Set a buffer-local mark to track the line position
	vim.api.nvim_buf_set_mark(bufnr, "I", line_num, 0, {})

	local sizes = vim.fn.input("Enter image sizes: ")
	if sizes == "" then
		print("No sizes provided")
		-- Clean up mark
		vim.api.nvim_buf_del_mark(bufnr, "I")
		return
	end

	local list_sizes = split(sizes, " ")

	local new_list_sizes = {}
	for _, size in ipairs(list_sizes) do
		table.insert(new_list_sizes, size)
		table.insert(new_list_sizes, "20")
	end

	list_sizes = new_list_sizes

	local suffixes = vim.fn.input("Enter image suffixes: ")
	if suffixes == "" then
		print("No suffixes provided")
		-- Clean up mark
		vim.api.nvim_buf_del_mark(bufnr, "I")
		return
	end

	local list_suffixes = split(suffixes, " ")

	local new_list_suffixes = {}
	for _, suffix in ipairs(list_suffixes) do
		local new_suffix = "-" .. suffix
		table.insert(new_list_suffixes, new_suffix)
		table.insert(new_list_suffixes, new_suffix .. "-tiny")
	end

	list_suffixes = new_list_suffixes

	print("\nSuffixes: " .. table.concat(list_suffixes, ", "))
	print("\nSizes to process: " .. table.concat(list_sizes, ", "))

	local path_name, source_path, base_name = move_image_from_downloads_dir()

	if not path_name or not source_path or not base_name then
		print("Error: Failed to move image")
		return
	end

	process_all_images(source_path, base_name, path_name, list_sizes, list_suffixes, bufnr, line_num)
end

return M
