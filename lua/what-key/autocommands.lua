local View = require('what-key.view')
local Keys = require('what-key.keys')

local M = {}

function M.setup(bufnr)
  local what_key_leader = '<Space>'
  local augroup = vim.api.nvim_create_augroup('WhatKey', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter' }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      vim.keymap.set('n', what_key_leader .. 's', function()
        if View.mod_target == Keys.MOD_TARGET_SHIFT then
          View.mod_target = nil
        else
          View.mod_target = Keys.MOD_TARGET_SHIFT
        end
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
        if View.mod_target == Keys.MOD_TARGET_CONTROL then
          View.mod_target = nil
        else
          View.mod_target = Keys.MOD_TARGET_CONTROL
        end
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
