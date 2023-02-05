local M = {}

M.mode = 'n'
M.mod_target = nil
M.prefix = ''

M.buf = nil
M.win = nil

function M.setup()
  M.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(M.buf, 'filetype', 'WhatKey')
  vim.api.nvim_buf_set_option(M.buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(M.buf, 'bufhidden', 'wipe')
  return M.buf
end

function M.show()
  if M.buf == nil or not vim.api.nvim_buf_is_valid(M.buf) then
    local bufnr = M.setup()
    require('what-key.autocommands').setup(bufnr)
  end

  local opts = {
    relative = 'editor',
    row = vim.o.lines,
    col = 0,
    width = vim.o.columns,
    height = 20,
    focusable = true,
    anchor = 'SW',
    border = 'none',
    style = 'minimal',
    noautocmd = false,
    title = 'What Key',
    title_pos = 'center',
  }

  M.win = vim.api.nvim_open_win(M.buf, true, opts)

  vim.api.nvim_win_set_option(M.win, 'foldmethod', 'manual')
  vim.api.nvim_win_set_option(M.win, 'winblend', 0)

  M.render()
end

function M.hide()
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
    vim.api.nvim_buf_delete(M.buf, { force = true })
    M.buf = nil
  end
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
  end
  vim.cmd('redraw')
end

function M.toggle()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    M.hide()
  else
    M.show()
  end
end

function M.render()
  vim.api.nvim_buf_set_option(M.buf, 'modifiable', true)

  local layout = require('what-key.layout').create_layout(M.win, M.mode, M.mod_target, M.prefix)

  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, layout.text)

  for _, highlights in ipairs(layout.highlights) do
    vim.api.nvim_buf_add_highlight(M.buf, -1, highlights.group, highlights.line_num, highlights.from, highlights.to)
  end

  vim.api.nvim_buf_set_option(M.buf, 'modifiable', false)
end

return M
