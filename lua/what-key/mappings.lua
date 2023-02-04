local M = {}

local Keys = require('what-key.keys')
local Utils = require('what-key.utils')

M.cached_mapping = nil

---Get first non-plug keymap
---@param lhs string
---@return string
function M.get_next_key(lhs)
  local first_key = string.sub(lhs, 1, 1)
  if first_key == '<' then
    first_key = string.match(lhs, '<.->')
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
function M.get_nested_mapping(mappings, keys)
  if #keys > 0 then
    local next = keys[1]

    if mappings[next] == nil then
      mappings[next] = Keys.init_key(Keys.USER_MAP)
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
}

---Get user mappings for mode
---@param mode string
---@return table
function M.create_mapping_for_mode(mode)
  -- TODO: only accept possible keys?
  -- local possible_keys = require('what-key.possible_keys').possible_keys()
  local result = {}

  local mode_mappings = vim.api.nvim_get_keymap(mode)
  for _, map in ipairs(mode_mappings) do
    if SKIP_LIST[M.get_next_key(map.lhs)] == nil then
      local split_keymap = M.split_keymap(map.lhs)
      local target_map = M.get_nested_mapping(result, split_keymap)
      -- target_map = vim.tbl_deep_extend('force', target_map, map)
      target_map.lhs = map.lhs
      target_map.rhs = map.rhs
      target_map.desc = map.desc
      -- result = vim.tbl_deep_extend('force', result, target_map)
    end
  end

  return result
end

function M.get_or_create_full_mapping()
  if M.cached_mapping == nil then
    -- local modes = { 'n', 'v', 's', 'x', 'o', '!', 'i', 'l', 'c', 't' } FIXME:
    local modes = { 'n', 'v' }
    local full_mapping = {}
    for _, mode in ipairs(modes) do
      full_mapping[mode] = M.create_mapping_for_mode(mode)
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

function M.transform_key_for_view(key)
  if key == ' ' then
    return '<Space>'
  end
  if key == '<lt>' then
    return '<'
  end
  return key
end

local function filter_out_control(key)
  return string.sub(key, 1, 3) ~= '<C-'
end

local function filter_control(key)
  return string.sub(key, 1, 3) == '<C-'
end

local function filter_out_shift(key)
  local target = string.sub(key, 1, 3)
  return not vim.tbl_contains(Keys.shift_keys, target)
end

local function filter_shift(key)
  local target = string.sub(key, 1, 3)
  return vim.tbl_contains(Keys.shift_keys, target)
end

local function filter_mapping(mapping, control, shift)
  if control then
    mapping = Utils.filter_tbl(filter_control, mapping)
  else
    mapping = Utils.filter_tbl(filter_out_control, mapping)
  end

  if shift then
    mapping = Utils.filter_tbl(filter_shift, mapping)
  else
    mapping = Utils.filter_tbl(filter_out_shift, mapping)
  end
  return mapping
end

---Only applies for the first layer (does not fill nested mappings)
local function fill_empty_mappings(mapping)
  local new_keys = {}
  for _, key in ipairs(Keys.keys()) do
    new_keys[key] = Keys.init_key(Keys.NO_MAP)
  end
  return vim.tbl_deep_extend('keep', mapping, new_keys)
end

---A filled mapping includes all mappings _with_ keys that are not mapped
function M.get_filled_filtered_mapping(mode, control, shift, prefix)
  local result = M.get_or_create_full_mapping()[mode]
  result = M.get_mapping_for_prefix(result, prefix)
  result = fill_empty_mappings(result)
  result = filter_mapping(result, control, shift)
  return result
end

-- print(M.get_filled_filtered_mapping('n', false, false, ','))

--TODO: get builtin vim mappings

-- P(M.create_mappings('v'))

return M
