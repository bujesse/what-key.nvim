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
function M.create_main_layout(win, mode, mod_target, prefix)
  local layout = {}
  local highlights = {}

  local top_padding = 4

  -- Set top padding
  M.render_vertical_padding(layout, top_padding)

  local total_lr_padding = 16
  local window_width = vim.api.nvim_win_get_width(win)
  local width = window_width - total_lr_padding

  local column_width = 14
  local num_columns = math.floor(width / column_width)
  local actual_lr_padding = window_width - (num_columns * column_width)
  local pad_left = math.floor(actual_lr_padding / 2)

  M.render_keyboard(layout, highlights, mode, mod_target, prefix, pad_left, column_width)

  -- M.render_vertical_padding(layout, 2)

  M.render_status_line(layout, highlights, mode, mod_target, prefix, window_width)

  return {
    text = layout,
    highlights = highlights,
    cursor_pos = { top_padding + 1, pad_left },
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
      view_prefix = view_prefix .. M.transform_view_key(c)
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

      local group
      local preview_text = ''
      local target_key = Keys.get_modded_key(global_key_id, mod_target)
      -- FIXME:error handling needed here in case a key isn't on the global map, or a mod doesn't exist
      if mappings[target_key] == nil then
        group = Colors.links.NoMapping
      else
        local map_type = mappings[target_key].mapped
        if next(mappings[target_key].mappings) == nil then
          group = HL_GROUPS_FOR_MAP_TYPE[map_type]
          if map_type ~= 'nomap' then
            preview_text = ' ' .. map_type
          end
        else
          group = Colors.links.NestedMapping
          preview_text = ' (' .. Mappings.count_nested_mappings(mappings[target_key].mappings) .. ')'
        end
      end

      -- Each cell gets its own highlighting
      table.insert(highlights, { group = group, line_num = kl_row_i + starting_line_num, from = start, to = ending })

      local view_key = M.transform_view_key(target_key)

      line = line
        .. '|'
        .. view_key
        .. '|'
        .. preview_text
        .. string.rep(' ', column_width - string.len(view_key) - 2 - string.len(preview_text))

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

---Transform either to or from the "view" key and the internal rep
function M.transform_view_key(key)
  local lookup = vim.tbl_add_reverse_lookup({
    [' '] = '<Space>',
    ['<'] = '<lt>',
    ['|'] = '<Bar>',
  })
  if lookup[key] ~= nil then
    return lookup[key]
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

---Create the help layout
---@return table<string>
function M.create_help_layout(win, mode, mod_target, prefix, target_key)
  local layout = {}
  local highlights = {}

  local top_padding = 3
  M.render_vertical_padding(layout, top_padding)

  local lr_padding = 8

  local target_mapping = Mappings.get_filled_filtered_mapping(mode, mod_target, prefix)[target_key]

  local split_prefix = Mappings.split_keymap(prefix)
  local line = string.rep(' ', lr_padding) .. 'Keymap: '
  for _, p in ipairs(split_prefix) do
    line = line .. M.transform_view_key(p)
  end
  line = line .. M.transform_view_key(target_key)
  table.insert(layout, line)

  local map_type = target_mapping.mapped
  if map_type == Keys.NO_MAP then
    table.insert(layout, string.rep(' ', lr_padding) .. 'No Mapping!')
  end

  if target_mapping.desc ~= nil then
    table.insert(layout, string.rep(' ', lr_padding) .. 'Desc: ' .. target_mapping.desc)
  end

  if target_mapping.rhs ~= nil then
    table.insert(layout, string.rep(' ', lr_padding) .. 'Mapping: ' .. target_mapping.rhs)
  end

  if not vim.tbl_isempty(target_mapping.mappings) then
    table.insert(
      layout,
      string.rep(' ', lr_padding) .. 'Nested Mappings: ' .. Mappings.count_nested_mappings(target_mapping.mappings)
    )
  end

  return {
    text = layout,
  }
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
