local M = {}

function M.run()
	local input = vim.fn.input("Enter two numbers: ")
	if input == "" then
		print("No input provided")
		return
	end

	local nums = vim.fn.split(input, " ")

	if #nums ~= 2 then
		vim.cmd("redraw")
		print("You need to enter two numbers")
		return
	end

	local result = 100 / tonumber(nums[1]) * tonumber(nums[2])
	local str = string.format("%.2f", result)

	vim.cmd("redraw")
	print(str)
end

return M
