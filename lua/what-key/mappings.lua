local M = {}

local Keys = require('what-key.keys')
local Utils = require('what-key.utils')

M.cached_mapping = nil

---Get first non-plug keymap
---@param lhs string
---@return string
function M.get_next_key(lhs)
  local first_key = string.sub(lhs, 1, 1)
  if lhs == '<' or lhs:find('<[^%u]') then
    first_key = lhs:gsub('<', '<lt>')
  elseif first_key == '<' then
    first_key = string.match(lhs, '<.->')
  elseif lhs:find('{.+}') then
    first_key = string.match(lhs, '{.+}')
  end
  return first_key
end

---Get first non-plug keymap
---@param lhs string
---@return Array
function M.split_keymap(lhs)
  local result = {}
  while string.len(lhs) > 0 do
    local next = M.get_next_key(lhs)
    table.insert(result, next)
    lhs = lhs:sub(string.len(next) + 1, string.len(lhs))
  end
  return result
end

---Recursively get reference to a nested mapping by split keys
---@param mappings table
---@param keys Array
---@return table
function M.get_nested_mapping(mappings, keys, init_as)
  if #keys > 0 then
    local next = keys[1]

    if mappings[next] == nil then
      mappings[next] = Keys.init_key(init_as)
    end

    local target_mapping = mappings[next]
    keys = { unpack(keys, 2) }
    if #keys == 0 then
      return target_mapping
    else
      return M.get_nested_mapping(target_mapping.mappings, keys)
    end
  end
  return mappings
end

local SKIP_LIST = {
  '<Plug>',
  '<c3>',
  '{motion}',
  '{char}',
  '{char1}',
  '{char2}',
  '{mark}',
  '{mode}',
  '{number}',
  '{register}',
  '{filter}',
  '{a-zA-Z0-9}',
  '{pattern}',
  '{a-z}',
  '{count}',
  '{height}',
  '{regname}',
}

---Get user mappings for mode
---@return table
function M.create_mapping(mappings, init_as)
  if not mappings then
    return {}
  end

  local result = {}

  for _, map in ipairs(mappings) do
    local skip = false
    for _, skip_str in ipairs(SKIP_LIST) do
      if string.find(map.lhs, skip_str) then
        skip = true
      end
    end
    if not skip then
      local split_keymap = M.split_keymap(map.lhs)
      local target_map = M.get_nested_mapping(result, split_keymap, init_as)
      -- target_map = vim.tbl_deep_extend('force', target_map, map)
      target_map.lhs = map.lhs
      target_map.rhs = map.rhs
      target_map.desc = map.desc
      target_map.mapped = init_as
      if init_as == Keys.VIM_MAP then
        target_map.help_str = map.help_str
      end
      -- result = vim.tbl_deep_extend('force', result, target_map)
    end
  end

  return result
end

function M.get_or_create_full_mapping()
  if M.cached_mapping == nil then
    local modes = {
      'n',
      'v',
      -- 's',
      -- 'x',
      'i',
      'l',
      'c',
      't',--[[ 'o', '!',  ]]
    }
    local full_mapping = {}

    local vim_index = M.get_vim_index_from_json()

    for _, mode in ipairs(modes) do
      -- User mappings
      local mode_mappings = vim.api.nvim_get_keymap(mode)
      full_mapping[mode] = M.create_mapping(mode_mappings, Keys.USER_MAP)

      -- Vim mappings
      local vim_mappings = M.create_mapping(vim_index[mode], Keys.VIM_MAP)
      full_mapping[mode] = vim.tbl_deep_extend('keep', full_mapping[mode], vim_mappings)
    end

    M.cached_mapping = full_mapping
  end
  return M.cached_mapping
end

---Get nested reference to a mapping by string prefix
---@param mapping table
---@param prefix string
---@return table
function M.get_mapping_for_prefix(mapping, prefix)
  local split_prefix = M.split_keymap(prefix)
  local result = M.get_nested_mapping(mapping, split_prefix)
  if prefix ~= '' then
    result = result.mappings
  end
  return result
end

---Only applies for the first layer (does not fill nested mappings)
local function fill_empty_mappings(mapping, mod_target, should_filter)
  local global_keys = Keys.get_global_keys(mod_target, true)
  if should_filter then
    local new_mapping = {}
    for key, map in pairs(mapping) do
      if global_keys[key] ~= nil then
        new_mapping[key] = map
      end
    end
    mapping = new_mapping
  end
  return vim.tbl_deep_extend('force', global_keys, mapping)
end

---A filled mapping includes all mappings _with_ keys that are not mapped
function M.get_filled_filtered_mapping(mode, mod_target, prefix)
  local result = M.get_or_create_full_mapping()[mode]
  result = M.get_mapping_for_prefix(result, prefix)
  result = fill_empty_mappings(result, mod_target, true)
  return result
end

---Takes a list of mappings and returns the recursive count of "lhs" values
function M.count_nested_mappings(mapping)
  if mapping == nil or vim.tbl_isempty(mapping) then
    return 0
  end

  local count = 0
  for _, map in pairs(mapping) do
    if map.lhs ~= nil then
      count = count + 1
    end
    count = count + M.count_nested_mappings(map.mappings)
  end

  return count
end

function M.get_vim_index_from_json()
  local file = io.open('vim_index_pp.json', 'rb')
  if file ~= nil then
    return vim.json.decode(file:read('*all'))
  end
  return nil
end

-- FIXME: this is just for testing
-- print(M.count_nested_mappings(M.get_filled_filtered_mapping('v', nil, '')['g'].mappings))

return M
