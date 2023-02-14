local Mappings = require('what-key.mappings')
local Keys = require('what-key.keys')
local Config = require('what-key.config').options

local M = {}

M.current_selected_layout = nil

local HL_GROUPS_FOR_MAP_TYPE = {
  [Keys.USER_MAP] = Config.highlights.UserMapping,
  [Keys.VIM_MAP] = Config.highlights.VimMapping,
  [Keys.NO_MAP] = Config.highlights.NoMapping,
}

---Since padding is determined by the keyboard layout, it's calculated and returned here
---@return integer
local function _render_keyboard(layout, highlights, mode, mod_target, prefix, window_width)
  local mappings = Mappings.get_filled_filtered_mapping(mode, mod_target, prefix)
  if M.current_selected_layout == nil then
    M.current_selected_layout = Config.default_keyboard_layout
  end

  local keyboard_layout = Config.keyboard_layouts[M.current_selected_layout]

  local column_width = 14

  -- Center the keyboard layout by its longest row
  local longest_row = 0
  for _, row in ipairs(keyboard_layout) do
    if #row > longest_row then
      longest_row = #row
    end
  end

  local widest_row_len = column_width * longest_row
  local pad_left
  if widest_row_len > window_width then
    pad_left = 0
  else
    local total_padding = window_width - widest_row_len
    pad_left = math.floor(total_padding / 2)
  end

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
        group = Config.highlights.NoMapping
      else
        local map_type = mappings[target_key].mapped
        if next(mappings[target_key].mappings) == nil then
          group = HL_GROUPS_FOR_MAP_TYPE[map_type]
          if map_type ~= 'nomap' then
            preview_text = ' ' .. map_type
          end
        else
          group = Config.highlights.NestedMapping
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
        .. string.rep(' ', column_width - vim.fn.strcharlen(view_key) - 2 - string.len(preview_text))

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

  return pad_left
end

local function _render_status_line(layout, highlights, mode, mod_target, prefix, window_width)
  local col_width = 25
  local view_prefix = ''
  if prefix == '' then
    view_prefix = 'None'
  else
    local split_prefix = Mappings.split_keymap(prefix)
    for _, c in ipairs(split_prefix) do
      view_prefix = view_prefix .. M.transform_view_key(c)
    end
  end
  local statuses = {
    'Mode: ' .. mode,
    'Mods: ' .. (mod_target or 'None'),
    'Prefix: ' .. view_prefix,
    'Layout: ' .. M.current_selected_layout,
  }
  local line = ''
  for i, status in ipairs(statuses) do
    line = line .. status
    if i ~= #statuses then
      line = line .. string.rep(' ', col_width - #status)
    end
  end

  local lr_padding = string.rep(' ', math.floor((window_width - #line) / 2))
  line = lr_padding .. line .. lr_padding
  table.insert(layout, line)
  return layout
end

local function _render_help_line(layout, highlights, window_width)
  local col_width = 35
  local keys = {
    'Append Current to prefix: ' .. Config.keymaps.append_prefix,
    'Pop from prefix: ' .. Config.keymaps.pop_prefix,
    'Toggle Shift: ' .. Config.keymaps.toggle_shift,
    'Toggle Control: ' .. Config.keymaps.toggle_control,
    'Enter Prefix: ' .. Config.keymaps.enter_prefix,
    'Change Mode: ' .. Config.keymaps.change_mode,
    'Change Layout: ' .. Config.keymaps.change_layout,
  }
  local line = ''
  for i, key in ipairs(keys) do
    line = line .. key
    if i ~= #keys then
      line = line .. string.rep(' ', col_width - #key)
    end
  end

  local lr_padding = string.rep(' ', math.floor((window_width - #line) / 2))
  line = lr_padding .. line .. lr_padding
  table.insert(layout, line)
  return layout
end

---Create the string layout
---@return table<string>
function M.create_main_layout(win, mode, mod_target, prefix)
  local layout = {}
  local highlights = {}

  local top_padding = 4

  -- Set top padding
  M.render_vertical_padding(layout, top_padding)
  local window_width = vim.api.nvim_win_get_width(win)

  local pad_left = _render_keyboard(layout, highlights, mode, mod_target, prefix, window_width)
  _render_status_line(layout, highlights, mode, mod_target, prefix, window_width)

  M.render_vertical_padding(layout, 2)

  _render_help_line(layout, highlights, window_width)

  return {
    text = layout,
    highlights = highlights,
    cursor_pos = { top_padding + 1, pad_left },
  }
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

  if target_mapping == nil then
    table.insert(layout, string.rep(' ', lr_padding) .. 'Key does not exist on layout')
    return {
      text = layout,
    }
  end

  local map_type = target_mapping.mapped
  if map_type == Keys.NO_MAP then
    table.insert(layout, string.rep(' ', lr_padding) .. 'No Mapping')
  elseif map_type == Keys.VIM_MAP then
    table.insert(layout, string.rep(' ', lr_padding) .. 'Mapped by: Vim')
  elseif map_type == Keys.USER_MAP then
    table.insert(layout, string.rep(' ', lr_padding) .. 'Mapped by: User')
  end

  if map_type == Keys.VIM_MAP and target_mapping.vim_desc ~= nil then
    table.insert(layout, string.rep(' ', lr_padding) .. 'Desc: ' .. target_mapping.vim_desc)
  elseif target_mapping.desc ~= nil then
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

return M
