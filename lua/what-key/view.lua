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

function M.get_first_key(lhs)
  return 'a'
end

---Get user mappings for mode
---@param mode string
---@return table
function M.get_user_mappings_for_mode(mode)
  local possible_keys = require('what-key.possible_keys').possible_keys()
  local registered_mappings = M.get_registered_mappings()

  local mode_mappings = vim.api.nvim_get_keymap(mode)
  for _, map in ipairs(mode_mappings) do
    local first_key = get_first_key(map.lhs)
    -- if (first_char == '<' and string.sub(map.lhs, 2, 2) ~= 'P') then P(map.lhs) end
    -- if (first_char == '>') then P(map) end
    if possible_keys[first_key] then
      possible_keys[first_key].user_mapping = true
    end
  end

  return possible_keys
end

--TODO: get builtin vim mappings

P(M.get_user_mappings_for_mode('v'))

return M
