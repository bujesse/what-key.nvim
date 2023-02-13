local Config = require('what-key.config').options

local M = {}

M.USER_MAP = 'user'
M.VIM_MAP = 'vim'
M.NO_MAP = 'nomap'

---@param mapped 'user' | 'vim' | 'nomap'
---@return table
function M.init_key(mapped)
  return { mapped = mapped, mappings = {} }
end

---Looks up by the global key ID and returns the key for the target mod. Returns nil if not found
---@param key string
---@param mod_target 'shift' | 'control' | 'meta'
---@return string | nil
function M.get_modded_key(key, mod_target)
  if not mod_target then
    return key
  end

  local globals = Config.global_keys
  if globals[key] ~= nil then
    return globals[key][mod_target]
  end

  return nil
end

M.MOD_TARGET_SHIFT = 'shift'
M.MOD_TARGET_CONTROL = 'control'
M.MOD_TARGET_META = 'meta'

---Get the global key list with optional modifier and optionally initialized
---@param mod_target 'shift' | 'control' | 'meta'
---@param init_no_map boolean Initialize with NO_MAP
---@return table
function M.get_global_keys(mod_target, init_no_map)
  local result = {}
  for origin_k, modded_k in pairs(Config.global_keys) do
    local new_target = nil
    if mod_target == nil then
      new_target = origin_k
    elseif modded_k[mod_target] ~= nil then
      new_target = modded_k[mod_target]
    else
      print('global key target: ' .. origin_k .. ' did not have a value for mod target: ' .. mod_target)
    end

    if new_target ~= nil then
      if init_no_map then
        result[new_target] = M.init_key(M.NO_MAP)
      else
        table.insert(result, new_target)
      end
    end
  end
  return result
end

return M
