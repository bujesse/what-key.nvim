local View = require('what-key.view')

local M = {}

function M.setup(bufnr)
  local what_key_leader = '<Space>'
  local augroup = vim.api.nvim_create_augroup('WhatKey', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter' }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      vim.keymap.set('n', what_key_leader .. 's', function()
        View.shift_on = not View.shift_on
        View.render()
      end, { buffer = bufnr })

      vim.keymap.set('n', what_key_leader .. 'v', function()
        View.mode = 'v'
        View.render()
      end, { buffer = bufnr })

      vim.keymap.set('n', what_key_leader .. 'n', function()
        View.mode = 'n'
        View.render()
      end, { buffer = bufnr })

      vim.keymap.set('n', what_key_leader .. 'i', function()
        View.mode = 'i'
        View.render()
      end, { buffer = bufnr })

      vim.keymap.set('n', what_key_leader .. 'c', function()
        View.control_on = not View.control_on
        View.render()
      end, { buffer = bufnr })

      vim.keymap.set('n', what_key_leader .. 'p', function()
        vim.ui.input({ prompt = 'Enter prefix (empty for no prefix): ' }, function(input)
          View.prefix = input
          View.render()
        end)
      end, { buffer = bufnr })
    end,
  })
end

return M
