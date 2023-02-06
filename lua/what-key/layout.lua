local Mappings = require('what-key.mappings')
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
function M.create_layout(win, mode, mod_target, prefix)
  local layout = {}
  local highlights = {}

  -- Set top padding
  M.render_vertical_padding(layout, 4)

  local total_lr_padding = 30
  local window_width = vim.api.nvim_win_get_width(win)
  local width = window_width - total_lr_padding

  local column_width = 15
  local num_columns = math.floor(width / column_width)
  local actual_lr_padding = window_width - (num_columns * column_width)
  local pad_left = math.floor(actual_lr_padding / 2)

  M.render_keyboard(layout, highlights, mode, mod_target, prefix, pad_left, column_width)

  -- M.render_vertical_padding(layout, 2)

  M.render_status_line(layout, highlights, mode, mod_target, prefix, window_width)

  return {
    text = layout,
    highlights = highlights,
  }
end

function M.render_status_line(layout, highlights, mode, mod_target, prefix, window_width)
  local col_width = 25
  local view_prefix = ''
  if prefix == '' then
    view_prefix = 'None'
  else
    local split_prefix = Mappings.split_keymap(prefix)
    for _, c in ipairs(split_prefix) do
      view_prefix = view_prefix .. M.transform_key_for_view(c)
    end
    view_prefix = '"' .. view_prefix .. '"'
  end
  local statuses = {
    'Mode: ' .. mode,
    'Mods: ' .. (mod_target or 'None'),
    'Prefix: ' .. view_prefix,
  }
  local line = ''
  for _, status in ipairs(statuses) do
    line = line .. status .. string.rep(' ', col_width - #status)
  end

  local lr_padding = string.rep(' ', math.floor((window_width - #line) / 2))
  line = lr_padding .. line .. lr_padding
  table.insert(layout, line)
  return layout
end

function M.render_keyboard(layout, highlights, mode, mod_target, prefix, pad_left, column_width)
  local mappings = Mappings.get_filled_filtered_mapping(mode, mod_target, prefix)
  local keyboard_layout = M.get_keyboard_layout()

  local start = 0
  local ending = start + column_width
  local starting_line_num = #layout - 1
  local line = ''
  for kl_row_i, kl_row in ipairs(keyboard_layout) do
    for kl_col_i, global_key_id in ipairs(kl_row) do
      if kl_col_i == 1 then
        start = start + pad_left
        ending = ending + pad_left
        line = line .. string.rep(' ', pad_left)
      end

      local target_key = Keys.get_modded_key(global_key_id, mod_target)
      -- FIXME:error handling needed here in case a key isn't on the global map, or a mod doesn't exist
      if mappings[target_key] ~= nil then
        local map_type = mappings[target_key].mapped
        local group = HL_GROUPS_FOR_MAP_TYPE[map_type]
        if next(mappings[target_key].mappings) ~= nil then
          group = Colors.links.NestedMapping
        end
        -- Each cell gets its own highlighting
        table.insert(highlights, { group = group, line_num = kl_row_i + starting_line_num, from = start, to = ending })
      end

      local view_key = M.transform_key_for_view(target_key)

      line = line .. view_key .. string.rep(' ', column_width - string.len(view_key))

      if kl_col_i == #kl_row then
        table.insert(layout, line)
        line = ''
        start = 0
        ending = start + column_width
      else
        start = ending
        ending = start + column_width
      end
    end
  end
  table.insert(layout, line)

  return layout
end

function M.transform_key_for_view(key)
  if key == ' ' then
    return '<Space>'
  end
  if key == '<lt>' then
    return '<'
  end
  return key
end

function M.get_keyboard_layout()
  return {
    { '<F1>', '<F2>', '<F3>', '<F4>', '<F5>', '<F6>', '<F7>', '<F8>', '<F9>', '<F10>', '<F11>', '<F12>' },
    { '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '<BS>', '<Del>' },
    { '<Tab>', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\\' },
    { 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '<CR>' },
    { 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/' },
    { ' ' },
  }
end

function M.render_vertical_padding(layout, padding_amount)
  for _ = 1, padding_amount do
    table.insert(layout, '')
  end
  return layout
end

-- Useful for debugging layout:
-- local View = require('what-key.view')
-- local bufnr = View.setup()
-- local opts = {
--   relative = 'editor',
--   row = vim.o.lines,
--   col = 0,
--   width = vim.o.columns,
--   height = 20,
--   focusable = true,
--   anchor = 'SW',
--   border = 'none',
--   style = 'minimal',
--   noautocmd = false,
--   title = 'What Key',
--   title_pos = 'center',
-- }
-- local win = vim.api.nvim_open_win(bufnr, false, opts)
-- M.create_layout(win, 'n', nil, '')

return M
