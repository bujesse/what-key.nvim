local M = {}

local possible_keys = require('what-key.possible_keys')

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
    -- -- Escape %
    -- next = next:gsub('%%', '%%%%', 1)
    -- -- Escape hyphen
    -- next = next:gsub('%-', '%%%-', 1)
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
      mappings[next] = possible_keys.init_key('user')
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

---Get user mappings for mode
---@param mode string
---@return table
function M.create_mapping(mode)
  -- TODO: only accept possible keys?
  -- local possible_keys = require('what-key.possible_keys').possible_keys()
  local result = {}

  local mode_mappings = vim.api.nvim_get_keymap(mode)
  for _, map in ipairs(mode_mappings) do
    local split_keymap = M.split_keymap(map.lhs)
    local target_map = M.get_nested_mapping(result, split_keymap)
    -- target_map = vim.tbl_deep_extend('force', target_map, map)
    target_map.lhs = map.lhs
    target_map.rhs = map.rhs
    target_map.desc = map.desc
    -- result = vim.tbl_deep_extend('force', result, target_map)
  end

  return result
end

function M.get_or_create_full_mapping()
  if M.cached_mapping == nil then
    local modes = { 'n', 'v', 's', 'x', 'o', '!', 'i', 'l', 'c', 't' }
    local full_mapping = {}
    for _, mode in ipairs(modes) do
      full_mapping[mode] = M.create_mapping(mode)
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
  return M.get_nested_mapping(mapping, split_prefix)
end

--TODO: get builtin vim mappings

-- P(M.create_mappings('v'))

return M
