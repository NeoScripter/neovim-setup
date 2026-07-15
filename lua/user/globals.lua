-- lua/globals.lua

_G.echo_error = function(msg)
	msg = msg or "Process aborted"
	vim.api.nvim_echo({ { "\n ✗ " .. msg, "ErrorMsg" } }, false, {})
end

_G.echo_success = function(msg)
	msg = msg or "Success!"
	vim.api.nvim_echo({ { "\n ✓ " .. msg } }, false, {})
end
