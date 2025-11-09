
--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

function source.new(opts)
  local self = setmetatable({}, { __index = source })
  self.opts = opts or {}
  return self
end

function source:get_completions(ctx, callback)
  local items = {}

  -- Get current line and cursor position
  local line_num = ctx.position.line
  local col_num = ctx.position.character
  local line = vim.api.nvim_buf_get_lines(ctx.bufnr, line_num, line_num + 1, false)[1] or ""

  -- Find the first space to the left
  local insert_col = 0
  for i = col_num, 1, -1 do
    if line:sub(i, i) == " " then
      insert_col = i
      break
    end
  end

  -- Create some example completion items
  for i = 1, 5 do
    local item = {
      label = "item " .. i,
      kind = require("blink.cmp.types").CompletionItemKind.Text,
      textEdit = {
        newText = "item " .. i,
        range = {
          start = { line = line_num, character = insert_col },
          ["end"] = { line = line_num, character = insert_col },
        },
      },
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
    }
    table.insert(items, item)
  end

  callback({ items = items })
end

return source
