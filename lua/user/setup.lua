local shada_path = vim.fn.stdpath("data") .. "/shada"
for _, file in ipairs(vim.fn.glob(shada_path .. "/main.shada.tmp.*", true, true)) do
	vim.fn.delete(file)
end

vim.notify = function(msg, log_level, _opts)
	if type(msg) == "string" and (msg:match("deprecated") or msg:match("Defining diagnostic signs")) then
		return
	end

	-- Uncomment to see other messages
	-- print("Notification:", msg)
end

vim.opt.langmap = {
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ",
  "фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"
}

