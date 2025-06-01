-- Start live-server in the current file's directory and open current file
vim.api.nvim_create_user_command("LiveServer", function()
  local file = vim.api.nvim_buf_get_name(0)
  if not file:match("%.html$") then
    vim.notify("Not an HTML file", vim.log.levels.WARN)
    return
  end
  local dir = vim.fn.fnamemodify(file, ":h")
  vim.fn.jobstart("live-server " .. dir, { detach = true })

  -- Open current file in browser (Windows only)
  vim.fn.jobstart("start " .. file, { detach = true })
end, {})

-- Stop live-server using taskkill (Windows only)
vim.api.nvim_create_user_command("StopLiveServer", function()
  vim.fn.jobstart("taskkill /IM live-server.exe /F", { detach = true })
  vim.notify("Live Server stopped", vim.log.levels.INFO)
end, {})

