local View = require('what-key.view')
local Keys = require('what-key.keys')
local Layout = require('what-key.layout')
local Mappings = require('what-key.mappings')
local Config = require('what-key.config')

local M = {}

local function _get_current_key_pos()
  local _, lnum, col = unpack(vim.fn.getcursorcharpos(0))
  local curr_line = vim.api.nvim_get_current_line()
  local start = col - 13
  if col <= 13 then
    start = 0
  end
  local start_pos, end_pos = string.find(curr_line, '|[^%s]-|', start)
  if start_pos == nil then
    return nil
  end
  -- Make 1-index for lua
  return {
    start = start_pos - 1,
    end_pos = end_pos,
    lnum = lnum - 1,
  }
end

---Returns the internal rep of a key
local function _get_current_key()
  local curr_line = vim.api.nvim_get_current_line()
  local curr_key_pos = _get_current_key_pos()
  if curr_key_pos ~= nil then
    local curr_key = string.match(curr_line, '|([^%s]-)|', curr_key_pos.start)
    curr_key = Layout.transform_view_key(curr_key)
    return curr_key
  end
  return nil
end

function M.setup(bufnr)
  local augroup = vim.api.nvim_create_augroup('WhatKey', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter' }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      vim.keymap.set('n', Config.what_key_keymaps.toggle_shift, function()
        if View.mod_target == Keys.MOD_TARGET_SHIFT then
          View.mod_target = nil
        else
          View.mod_target = Keys.MOD_TARGET_SHIFT
        end
        View.render()
      end, { buffer = bufnr })

      vim.keymap.set('n', Config.what_key_keymaps.change_mode, function()
        vim.ui.select({ '[n]ormal', '[v]isual', '[i]nsert', '[c]ommand' }, {
          prompt = 'Select mode:',
        }, function(choice, idx)
          if idx == 1 then
            View.mode = 'n'
          elseif idx == 2 then
            View.mode = 'v'
          elseif idx == 3 then
            View.mode = 'i'
          elseif idx == 4 then
            View.mode = 'c'
          end
          View.render()
        end)
      end, { buffer = bufnr })

      vim.keymap.set('n', Config.what_key_keymaps.toggle_control, function()
        if View.mod_target == Keys.MOD_TARGET_CONTROL then
          View.mod_target = nil
        else
          View.mod_target = Keys.MOD_TARGET_CONTROL
        end
        View.render()
      end, { buffer = bufnr })

      vim.keymap.set('n', Config.what_key_keymaps.enter_prefix, function()
        vim.ui.input({ prompt = 'Enter prefix (empty for no prefix): ' }, function(input)
          if input ~= nil and input ~= '' then
            View.prefix = input
            View.render()
          end
        end)
      end, { buffer = bufnr })

      vim.keymap.set('n', Config.what_key_keymaps.append_prefix, function()
        local curr_key = _get_current_key()
        if curr_key ~= nil then
          View.prefix = View.prefix .. curr_key
          View.render()
        end
      end, { buffer = bufnr })

      vim.keymap.set('n', Config.what_key_keymaps.pop_prefix, function()
        if View.prefix ~= '' then
          local split_prefix = Mappings.split_keymap(View.prefix)
          table.remove(split_prefix)
          View.prefix = table.concat(split_prefix)
          View.render()
        end
      end, { buffer = bufnr })
    end,
  })

  local curr_key_ns = vim.api.nvim_create_namespace('WhatKeyCurrentKey')

  vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      local curr_key = _get_current_key()
      if curr_key ~= nil then
        local curr_key_pos = _get_current_key_pos()
        vim.api.nvim_buf_clear_namespace(bufnr, curr_key_ns, 0, -1)
        vim.api.nvim_buf_add_highlight(bufnr, curr_key_ns, 'IncSearch', curr_key_pos.lnum, curr_key_pos.start, curr_key_pos.end_pos)

        View.show_help(curr_key)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'WinLeave' }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      View.hide_help()
    end,
  })
end

return M
