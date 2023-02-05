local M = {}

M.USER_MAP = 'user'
M.VIM_MAP = 'vim'
M.NO_MAP = 'nomap'

---@param mapped 'user' | 'vim' | 'nomap'
---@return table
function M.init_key(mapped)
  return { mapped = mapped, mappings = {} }
end

function M._global_keys()
  return {
    ['a'] = { shift = 'A', control = '<C-A>', meta = nil },
    ['b'] = { shift = 'B', control = '<C-B>', meta = nil },
    ['c'] = { shift = 'C', control = '<C-C>', meta = nil },
    ['d'] = { shift = 'D', control = '<C-D>', meta = nil },
    ['e'] = { shift = 'E', control = '<C-E>', meta = nil },
    ['f'] = { shift = 'F', control = '<C-F>', meta = nil },
    ['g'] = { shift = 'G', control = '<C-G>', meta = nil },
    ['h'] = { shift = 'H', control = '<C-H>', meta = nil },
    ['i'] = { shift = 'I', control = '<C-I>', meta = nil },
    ['j'] = { shift = 'J', control = '<C-J>', meta = nil },
    ['k'] = { shift = 'K', control = '<C-K>', meta = nil },
    ['l'] = { shift = 'L', control = '<C-L>', meta = nil },
    ['m'] = { shift = 'M', control = '<C-M>', meta = nil },
    ['n'] = { shift = 'N', control = '<C-N>', meta = nil },
    ['o'] = { shift = 'O', control = '<C-O>', meta = nil },
    ['p'] = { shift = 'P', control = '<C-P>', meta = nil },
    ['q'] = { shift = 'Q', control = '<C-Q>', meta = nil },
    ['r'] = { shift = 'R', control = '<C-R>', meta = nil },
    ['s'] = { shift = 'S', control = '<C-S>', meta = nil },
    ['t'] = { shift = 'T', control = '<C-T>', meta = nil },
    ['u'] = { shift = 'U', control = '<C-U>', meta = nil },
    ['v'] = { shift = 'V', control = '<C-V>', meta = nil },
    ['w'] = { shift = 'W', control = '<C-W>', meta = nil },
    ['x'] = { shift = 'X', control = '<C-X>', meta = nil },
    ['y'] = { shift = 'Y', control = '<C-Y>', meta = nil },
    ['z'] = { shift = 'Z', control = '<C-Z>', meta = nil },
    [' '] = { shift = '<S-Space>', control = '<C-Space>', meta = nil },
    [';'] = { shift = ':', control = '<C-;>', meta = nil },
    ["'"] = { shift = '"', control = "<C-'>", meta = nil },
    [','] = { shift = '<lt>', control = '<C-,>', meta = nil },
    ['.'] = { shift = '>', control = '<C-.>', meta = nil },
    ['['] = { shift = '{', control = '<C-[>', meta = nil },
    [']'] = { shift = '}', control = '<C-]>', meta = nil },
    ['-'] = { shift = '_', control = '<C-->', meta = nil },
    ['='] = { shift = '+', control = '<C-=>', meta = nil },
    ['`'] = { shift = '~', control = '<C-`>', meta = nil },
    ['\\'] = { shift = '|', control = '<C-Bslash>', meta = nil },
    ['/'] = { shift = '?', control = '<C-/>', meta = nil },
    ['0'] = { shift = '!', control = '<C-0>', meta = nil },
    ['1'] = { shift = '@', control = '<C-1>', meta = nil },
    ['2'] = { shift = '#', control = '<C-2>', meta = nil },
    ['3'] = { shift = '$', control = '<C-3>', meta = nil },
    ['4'] = { shift = '%', control = '<C-4>', meta = nil },
    ['5'] = { shift = '^', control = '<C-5>', meta = nil },
    ['6'] = { shift = '&', control = '<C-6>', meta = nil },
    ['7'] = { shift = '*', control = '<C-7>', meta = nil },
    ['8'] = { shift = '(', control = '<C-8>', meta = nil },
    ['9'] = { shift = ')', control = '<C-9>', meta = nil },
    ['<BS>'] = { shift = '<,-BS>', control = '<C-BS>', meta = '<M-BS>' },
    ['<Del>'] = { shift = '<S-Del>', control = '<C-Del>', meta = '<M-Del>' },
    ['<CR>'] = { shift = '<S-CR>', control = '<C-CR>', meta = '<M-CR>' },
    ['<Tab>'] = { shift = '<S-Tab>', control = '<C-Tab>', meta = nil },
    ['<Up>'] = { shift = '<S-Up>', control = '<C-Up>', meta = '<M-Up>' },
    ['<Down>'] = { shift = '<S-Down>', control = '<C-Down>', meta = '<M-Down>' },
    ['<Left>'] = { shift = '<S-Left>', control = '<C-Left>', meta = '<M-Left>' },
    ['<Right>'] = { shift = '<S-Right>', control = '<C-Right>', meta = '<M-Right>' },
    ['<F1>'] = { shift = '<S-F1>', control = '<C-F1>', meta = nil },
    ['<F2>'] = { shift = '<S-F2>', control = '<C-F2>', meta = nil },
    ['<F3>'] = { shift = '<S-F3>', control = '<C-F3>', meta = nil },
    ['<F4>'] = { shift = '<S-F4>', control = '<C-F4>', meta = nil },
    ['<F5>'] = { shift = '<S-F5>', control = '<C-F5>', meta = nil },
    ['<F6>'] = { shift = '<S-F6>', control = '<C-F6>', meta = nil },
    ['<F7>'] = { shift = '<S-F7>', control = '<C-F7>', meta = nil },
    ['<F8>'] = { shift = '<S-F8>', control = '<C-F8>', meta = nil },
    ['<F9>'] = { shift = '<S-F9>', control = '<C-F9>', meta = nil },
    ['<F10>'] = { shift = '<S-F10>', control = '<C-F10>', meta = nil },
    ['<F11>'] = { shift = '<S-F11>', control = '<C-F11>', meta = nil },
    ['<F12>'] = { shift = '<S-F12>', control = '<C-F12>', meta = nil },
    -- TODO: add numpad, other nav cluster keys
  }
end

---Looks up by the global key ID and returns the key for the target mod. Returns nil if not found
---@param key string
---@param mod_target 'shift' | 'control' | 'meta'
---@return string | nil
function M.get_modded_key(key, mod_target)
  if not mod_target then
    return key
  end

  local globals = M._global_keys()
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
  for origin_k, modded_k in pairs(M._global_keys()) do
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
