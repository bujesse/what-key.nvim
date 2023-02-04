local M = {}

M.mode = 'n'
M.buf = nil
M.win = nil

function M.show()
  -- local width = round(ui.width * 0.5)
  -- local height = round(ui.height * 0.5)

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
    noautocmd = true,
    title = 'What Key',
    title_pos = 'center',
  }

  M.buf = vim.api.nvim_create_buf(false, true)
  -- M.win = vim.api.nvim_open_win(M.buf, true, opts)
  M.win = vim.api.nvim_open_win(M.buf, false, opts) -- FIXME: use for dev only

  vim.api.nvim_buf_set_option(M.buf, 'filetype', 'WhatKey')
  vim.api.nvim_buf_set_option(M.buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(M.buf, 'bufhidden', 'wipe')

  vim.api.nvim_win_set_option(M.win, 'foldmethod', 'manual')
  vim.api.nvim_win_set_option(M.win, 'winblend', 0)

  local layout = require('what-key.layout').create_layout(M.win)
  M.render(layout)

  vim.api.nvim_buf_set_option(M.buf, 'modifiable', false)
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

function M.render(layout)
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, layout.text)

  for _, highlights in ipairs(layout.highlights) do
    vim.api.nvim_buf_add_highlight(M.buf, -1, highlights.group, highlights.line_num, highlights.from, highlights.to)
  end
end

return M
