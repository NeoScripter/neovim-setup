local M = {}

function M.snake_to_camel(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	-- Split on underscores, preserving structure
	local parts = {}
	for part in str:gmatch("([^_]*)_?") do
		table.insert(parts, part)
	end
	-- gmatch with this pattern can leave a trailing empty match; drop it
	if parts[#parts] == "" then
		table.remove(parts)
	end

	if #parts == 0 then
		return ""
	end

	local result = { parts[1]:lower() }
	for i = 2, #parts do
		local part = parts[i]
		if part ~= "" then
			-- Capitalize first letter, keep rest as-is (preserves acronyms like "ID", "URL")
			result[#result + 1] = part:sub(1, 1):upper() .. part:sub(2)
		end
	end

	return table.concat(result)
end

function M.camel_to_snake(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	local result = str
		-- Insert an underscore between a run of capitals and a following Capital+lowercase
		-- e.g. "XMLParser" -> "XML_Parser"
		:gsub(
			"(%u+)(%u%l)",
			"%1_%2"
		)
		-- Insert an underscore between a lowercase/digit and an uppercase letter
		-- e.g. "userID" -> "user_ID", "value2Name" -> "value2_Name"
		:gsub(
			"(%l%d*)(%u)",
			"%1_%2"
		)

	result = result:lower()

	-- Collapse any accidental double underscores and trim leading/trailing ones
	result = result:gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")

	return result
end

function M.camel_to_kebab(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end
	local result = str
		-- Insert a hyphen between a run of capitals and a following Capital+lowercase
		-- e.g. "XMLParser" -> "XML-Parser"
		:gsub(
			"(%u+)(%u%l)",
			"%1-%2"
		)
		-- Insert a hyphen between a lowercase/digit and an uppercase letter
		-- e.g. "userID" -> "user-ID", "value2Name" -> "value2-Name"
		:gsub(
			"(%l%d*)(%u)",
			"%1-%2"
		)
	result = result:lower()
	-- Collapse any accidental double hyphens and trim leading/trailing ones
	result = result:gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
	return result
end

function M.kebab_to_camel(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end
	-- Split on hyphens, preserving structure
	local parts = {}
	for part in str:gmatch("([^%-]*)%-?") do
		table.insert(parts, part)
	end
	-- gmatch with this pattern can leave a trailing empty match; drop it
	if parts[#parts] == "" then
		table.remove(parts)
	end
	if #parts == 0 then
		return ""
	end
	local result = { parts[1]:lower() }
	for i = 2, #parts do
		local part = parts[i]
		if part ~= "" then
			-- Capitalize first letter, keep rest as-is (preserves acronyms like "ID", "URL")
			result[#result + 1] = part:sub(1, 1):upper() .. part:sub(2)
		end
	end
	return table.concat(result)
end

function M.kebab_to_pascal(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end
	-- Split on hyphens, preserving structure
	local parts = {}
	for part in str:gmatch("([^%-]*)%-?") do
		table.insert(parts, part)
	end
	-- gmatch with this pattern can leave a trailing empty match; drop it
	if parts[#parts] == "" then
		table.remove(parts)
	end
	if #parts == 0 then
		return ""
	end
	local result = {}
	for i = 1, #parts do
		local part = parts[i]
		if part ~= "" then
			-- Capitalize first letter, keep rest as-is (preserves acronyms like "ID", "URL")
			result[#result + 1] = part:sub(1, 1):upper() .. part:sub(2)
		end
	end
	return table.concat(result)
end

return M
