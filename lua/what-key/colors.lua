local M = {}

M.links = {
  -- NoMapping = 'CurSearch',
  -- UserMapping = 'CursorLine',
  -- NestedMapping = 'IncSearch',
  NoMapping = 'String',
  UserMapping = 'Constant',
  VimMapping = 'Identifier',
  NestedMapping = 'Conditional',
}

function M.setup()
  for k, v in pairs(M.links) do
    vim.api.nvim_set_hl(0, 'WhatKey' .. k, { link = v, default = true })
  end
end

return M
