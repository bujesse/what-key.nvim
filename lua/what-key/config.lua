local M = {}

local what_key_leader = '<Space>'

M.what_key_keymaps = {
  toggle_shift = what_key_leader .. 's',
  toggle_control = what_key_leader .. 'c',
  enter_prefix = what_key_leader .. 'p',
  change_mode = what_key_leader .. 'm',
  append_prefix = '<CR>',
  pop_prefix = '<Backspace>',
}

return M
