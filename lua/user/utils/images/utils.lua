local M = {}

function M.get_project_root()
	return vim.fs.root(0, { ".git", "package.json", "composer.json", "vite.config", "node_modules", "index.html" })
end

function M.convert_image_to(format, path)
	local ext = path:match("%.([%w]+)$")
	local output = path:gsub(ext, format)

	if format == "webp" then
		vim.fn.system({ "cwebp", path, "-q", "75", "-m", "6", "-o", output })
	elseif format == "avif" then
        -- stylua: ignore
         vim.fn.system({ "avifenc", "-a", "cq-level=38", "-a", "tune=ssim", "--speed", "6", "--yuv", "420", path, "-o", output })
	elseif format == "jpg" then
		vim.fn.system({ "convert", path, output })
		vim.fn.system({ "jpegoptim", "-m75", output })
	elseif format == "png" then
		vim.fn.system({ "convert", path, output })
		vim.fn.system({ "oxipng", "-o", "2", "--strip", "safe", "--alpha", output })
	end

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "\n ✗ Convertion failed: " .. output, "ErrorMsg" },
		}, false, {})
		return nil
	end

	return output
end

function M.resize_image_to(size, path, new_path)
    -- stylua: ignore
    local output = vim.fn.system({ "convert", path, "-filter", "Lanczos", "-resize", size .. "x", new_path })

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "\n ✗ Resize failed: " .. output, "ErrorMsg" },
		}, false, {})
		return nil
	end

	return new_path
end

function M.split(s, sep)
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	s:gsub(pattern, function(c)
		fields[#fields + 1] = c
	end)
	return fields
end

return M
