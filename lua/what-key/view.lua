local M = {}

function M.show()
  M.buf = vim.api.nvim_create_buf(false, true)
  M.win = vim.api.nvim_open_win(M.buf, false, {
    relative = 'editor',
    row = vim.o.lines,
    col = 1,
    width = vim.o.columns,
    height = 10,
    focusable = false,
    anchor = 'SW',
    style = 'minimal',
    noautocmd = true,
  })

  vim.api.nvim_buf_set_option(M.buf, 'filetype', 'WhatKey')
  vim.api.nvim_buf_set_option(M.buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(M.buf, 'bufhidden', 'wipe')
  vim.api.nvim_win_set_option(M.win, 'foldmethod', 'manual')
end

function M.get_registered_mappings()
  local mappings = {}
  for _, mode in ipairs({ 'n', 'i' }) do
    local mode_mappings = vim.api.nvim_get_keymap(mode)
    for _, mapping in ipairs(mode_mappings) do
      table.insert(mappings, { mode = mode, lhs = mapping.lhs, rhs = mapping.rhs })
      -- -- ensure only telescope mappings
      -- if mapping.rhs and string.find(mapping.rhs, [[require%('telescope.mappings'%).execute_keymap]]) then
      --   local funcid = findnth(mapping.rhs, 2)
      --   table.insert(ret, { mode = mode, keybind = mapping.lhs, func = __TelescopeKeymapStore[prompt_bufnr][funcid] })
      -- end
    end
  end
  return mappings
end

---Get Available Keys For Mode
---@param mode string
---@return table
function M.get_available_keys_for_mode(mode)
  local possible_keys = require('what-key.possible_keys').possible_keys()
  local registered_mappings = M.get_registered_mappings()

  local mode_mappings = vim.api.nvim_get_keymap(mode)
  P(mode_mappings)
  for _, map in ipairs(mode_mappings) do
    local first_char = string.sub(map.lhs, 1, 1)
    if possible_keys[first_char] ~= nil then
      possible_keys[first_char] = nil
    end
  end
  return possible_keys
end

P(M.get_available_keys_for_mode('n'))

return M
