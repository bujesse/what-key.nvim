local mappings = require('what-key.mappings')

local M = {}

---Create the string layout
---@return table<string>
function M.create_layout(win)
  local mode = 'n'
  local mappings = mappings.get_or_create_full_mapping()[mode]

  local padding = 10
  local window_width = vim.api.nvim_win_get_width(win)
  local width = window_width - padding

  local column_width = 15

  local num_columns = math.floor(width / column_width)
  local col = 1
  local row = 1
  local pad_top = 10
  local pad_left = 10

  local result = {
    'window_width: ' .. vim.api.nvim_win_get_width(win),
    'window_width with padding: ' .. window_width,
    'columns ' .. num_columns,
  }

  local line = ''
  for key, map in pairs(mappings) do
    if col == 1 then
      line = line .. string.rep(' ', pad_left)
    end

    line = line .. key .. string.rep(' ', column_width - string.len(key))

    col = col + 1
    if col == column_width then
      table.insert(result, line)
      col = 1
      line = ''
    end
  end

  return result
end

function M.create_line(row, col, str)
  return
end

return M
