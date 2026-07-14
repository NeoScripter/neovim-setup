local M = {}

function M.get_project_root()
	return vim.fs.root(0, { ".git", "package.json", "composer.json", "vite.config", "node_modules", "index.html" })
end

return M
