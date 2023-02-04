local Mappings = require('what-key.mappings')
local Utils = require('what-key.utils')

local M = {}

---Create the string layout
---@return table<string>
function M.create_layout(win)
  local mappings = Mappings.get_filled_filtered_mapping('n', false, false, '')

  local padding = 10
  local window_width = vim.api.nvim_win_get_width(win)
  local width = window_width - padding

  local column_width = 15

  local num_columns = math.floor(width / column_width)
  local col = 1
  local row = 1
  local pad_top = 10
  local pad_left = 10

  local result = {}

  local sorted_keys = Utils.get_sorted_keys(mappings)
  local line = ''
  for _, key in ipairs(sorted_keys) do
    if col == 1 then
      line = line .. string.rep(' ', pad_left)
    end

    key = Mappings.transform_key_for_view(key)

    line = line .. key .. string.rep(' ', column_width - string.len(key))

    col = col + 1
    if col == column_width then
      table.insert(result, line)
      col = 1
      line = ''
    end
  end

  table.insert(result, line)
  return result
end

function M.create_line(row, col, str)
  return
end

return M
