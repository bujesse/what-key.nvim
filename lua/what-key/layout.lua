local Mappings = require('what-key.mappings')
local Utils = require('what-key.utils')
local Keys = require('what-key.keys')
local Colors = require('what-key.colors')

local M = {}

local HL_GROUPS_FOR_MAP_TYPE = {
  [Keys.USER_MAP] = Colors.links.UserMapping,
  [Keys.VIM_MAP] = Colors.links.VimMapping,
  [Keys.NO_MAP] = Colors.links.NoMapping,
}

---Create the string layout
---@return table<string>
function M.create_layout(win, mode, control, shift, prefix)
  local result = {}

  -- Set top padding
  local pad_top = 4
  for i = 1, pad_top do
    table.insert(result, '')
  end

  local total_lr_padding = 30
  local window_width = vim.api.nvim_win_get_width(win)
  local width = window_width - total_lr_padding
  local column_width = 25
  local num_columns = math.floor(width / column_width)
  local actual_lr_padding = window_width - (num_columns * column_width)
  local pad_left = math.floor(actual_lr_padding / 2)

  local col = 1
  local highlights = {}

  local line_num = pad_top
  local start = 0
  local ending = start + column_width

  local mappings = Mappings.get_filled_filtered_mapping(mode, control, shift, prefix)
  local sorted_keys = Utils.get_sorted_keys(mappings)
  local line = ''
  for _, key in ipairs(sorted_keys) do
    if col == 1 then
      start = start + pad_left
      ending = ending + pad_left
      line = line .. string.rep(' ', pad_left)
    end

    if mappings[key] ~= nil then
      local group = HL_GROUPS_FOR_MAP_TYPE[mappings[key].mapped]
      if next(mappings[key].mappings) ~= nil then
        group = Colors.links.NestedMapping
      end
      -- Each cell gets its own highlighting
      table.insert(highlights, { group = group, line_num = line_num, from = start, to = ending })
    end

    local view_key = Mappings.transform_key_for_view(key)

    line = line .. view_key .. string.rep(' ', column_width - string.len(view_key))

    if col == num_columns then
      table.insert(result, line)
      col = 1
      line = ''
      line_num = line_num + 1
      start = 0
      ending = start + column_width
    else
      start = ending
      ending = start + column_width
      col = col + 1
    end
  end

  table.insert(result, line)
  return {
    text = result,
    highlights = highlights,
  }
end

return M
