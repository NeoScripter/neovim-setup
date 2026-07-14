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
         vim.fn.system({ "avifenc", "-a", "cq-level=38", "-a", "tune=ssim", "--speed", "6", "--yuv", "420", path, "-o", output, })
	elseif format == "jpg" then
		vim.fn.system({ "convert", path, output })
		vim.fn.system({ "jpegoptim", "-m75", output })
	elseif format == "png" then
		vim.fn.system({ "convert", path, output })
		vim.fn.system({ "oxipng", "-o", "2", "--strip", "safe", "--alpha", output })
	end

	return output
end

function M.resize_image_to(size, path, new_path)
	vim.fn.system({ "convert", path, "-resize", size, "x>", new_path })

	return new_path
end

return M
