local M = {}

function M.snake_to_camel(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("%_%l", string.upper)
	str = str:gsub("[-_]", "")
	return str
end

function M.camel_to_snake(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	return str:gsub("%u", function(char)
		return "_" .. string.lower(char)
	end)
end

function M.camel_to_kebab(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	return str:gsub("%u", function(char)
		return "-" .. string.lower(char)
	end)
end

function M.kebab_to_camel(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("%-%l", string.upper)
	str = str:gsub("[-_]", "")
	return str
end

function M.pascal_to_kebab(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("^%u", string.lower)

	return str:gsub("%u", function(char)
		return "-" .. string.lower(char)
	end)
end

function M.pascal_to_snake(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("^%u", string.lower)

	return str:gsub("%u", function(char)
		return "_" .. string.lower(char)
	end)
end

function M.kebab_to_pascal(str)
	if type(str) ~= "string" or str == "" then
		return str or ""
	end

	str = str:gsub("^%l", string.upper)

	str = str:gsub("%-%l", string.upper)
	return str:gsub("[-_]", "")
end

return M
