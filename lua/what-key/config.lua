local M = {}

---@class WhatKeyOptions
M.defaults = {
  keymaps = {
    toggle_shift = '<Space>s',
    toggle_control = '<Space>c',
    enter_prefix = '<Space>p',
    change_mode = '<Space>m',
    change_layout = '<Space>l',
    append_prefix = '<CR>',
    pop_prefix = '<Backspace>',
  },

  highlights = {
    NoMapping = 'String',
    UserMapping = 'Constant',
    VimMapping = 'Identifier',
    NestedMapping = 'Conditional',
    HighlightCurrentKey = 'IncSearch',
  },

  keyboard_layouts = {
    default = {
      { '<Esc>', '<F1>', '<F2>', '<F3>', '<F4>', '<F5>', '<F6>', '<F7>', '<F8>', '<F9>', '<F10>', '<F11>', '<F12>' },
      { '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '<BS>', '<Del>' },
      { '<Tab>', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\\' },
      { 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '<CR>' },
      { 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/' },
      { ' ' },
    },
    hhkb = {
      { '<Esc>', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\\', '`' },
      { '<Tab>', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '<BS>' },
      { 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '<CR>' },
      { 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/' },
      { ' ' },
    },
    uk = {
      { '<Esc>', '<F1>', '<F2>', '<F3>', '<F4>', '<F5>', '<F6>', '<F7>', '<F8>', '<F9>', '<F10>', '<F11>', '<F12>' },
      { '`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '<BS>', '<Del>' },
      { '<Tab>', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']' },
      { 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '#', '<CR>' },
      { '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/' },
      { ' ' },
    },
  },

  default_keyboard_layout = 'default',

  global_keys = {
    ['a'] = { shift = 'A', control = '<C-A>', meta = '<M-A>' },
    ['b'] = { shift = 'B', control = '<C-B>', meta = '<M-B>' },
    ['c'] = { shift = 'C', control = '<C-C>', meta = '<M-C>' },
    ['d'] = { shift = 'D', control = '<C-D>', meta = '<M-D>' },
    ['e'] = { shift = 'E', control = '<C-E>', meta = '<M-E>' },
    ['f'] = { shift = 'F', control = '<C-F>', meta = '<M-F>' },
    ['g'] = { shift = 'G', control = '<C-G>', meta = '<M-G>' },
    ['h'] = { shift = 'H', control = '<C-H>', meta = '<M-H>' },
    ['i'] = { shift = 'I', control = '<C-I>', meta = '<M-I>' },
    ['j'] = { shift = 'J', control = '<C-J>', meta = '<M-J>' },
    ['k'] = { shift = 'K', control = '<C-K>', meta = '<M-K>' },
    ['l'] = { shift = 'L', control = '<C-L>', meta = '<M-L>' },
    ['m'] = { shift = 'M', control = '<C-M>', meta = '<M-M>' },
    ['n'] = { shift = 'N', control = '<C-N>', meta = '<M-N>' },
    ['o'] = { shift = 'O', control = '<C-O>', meta = '<M-O>' },
    ['p'] = { shift = 'P', control = '<C-P>', meta = '<M-P>' },
    ['q'] = { shift = 'Q', control = '<C-Q>', meta = '<M-Q>' },
    ['r'] = { shift = 'R', control = '<C-R>', meta = '<M-R>' },
    ['s'] = { shift = 'S', control = '<C-S>', meta = '<M-S>' },
    ['t'] = { shift = 'T', control = '<C-T>', meta = '<M-T>' },
    ['u'] = { shift = 'U', control = '<C-U>', meta = '<M-U>' },
    ['v'] = { shift = 'V', control = '<C-V>', meta = '<M-V>' },
    ['w'] = { shift = 'W', control = '<C-W>', meta = '<M-W>' },
    ['x'] = { shift = 'X', control = '<C-X>', meta = '<M-X>' },
    ['y'] = { shift = 'Y', control = '<C-Y>', meta = '<M-Y>' },
    ['z'] = { shift = 'Z', control = '<C-Z>', meta = '<M-Z>' },
    [' '] = { shift = '<S-Space>', control = '<C-Space>', meta = '<M-Space>' },
    [';'] = { shift = ':', control = '<C-;>', meta = '<M-;>' },
    ["'"] = { shift = '"', control = "<C-'>", meta = nil },
    [','] = { shift = '<lt>', control = '<C-,>', meta = '<M-,>' },
    ['.'] = { shift = '>', control = '<C-.>', meta = '<M-.>' },
    ['['] = { shift = '{', control = '<C-[>', meta = '<M-[>' },
    [']'] = { shift = '}', control = '<C-]>', meta = '<M-]>' },
    ['-'] = { shift = '_', control = '<C-->', meta = '<M-->' },
    ['='] = { shift = '+', control = '<C-=>', meta = '<M-=>' },
    ['`'] = { shift = '~', control = '<C-`>', meta = '<M-`>' },
    ['\\'] = { shift = '|', control = '<C-Bslash>', meta = '<M-Bslash>' },
    ['/'] = { shift = '?', control = '<C-/>', meta = '<M-/>' },
    ['0'] = { shift = '!', control = '<C-0>', meta = '<M-0>' },
    ['1'] = { shift = '@', control = '<C-1>', meta = '<M-1>' },
    ['2'] = { shift = '#', control = '<C-2>', meta = '<M-2>' },
    ['3'] = { shift = '$', control = '<C-3>', meta = '<M-3>' },
    ['4'] = { shift = '%', control = '<C-4>', meta = '<M-4>' },
    ['5'] = { shift = '^', control = '<C-5>', meta = '<M-5>' },
    ['6'] = { shift = '&', control = '<C-6>', meta = '<M-6>' },
    ['7'] = { shift = '*', control = '<C-7>', meta = '<M-7>' },
    ['8'] = { shift = '(', control = '<C-8>', meta = '<M-8>' },
    ['9'] = { shift = ')', control = '<C-9>', meta = '<M-9>' },
    ['<BS>'] = { shift = '<S-BS>', control = '<C-BS>', meta = '<M-BS>' },
    ['<Del>'] = { shift = '<S-Del>', control = '<C-Del>', meta = '<M-Del>' },
    ['<CR>'] = { shift = '<S-CR>', control = '<C-CR>', meta = '<M-CR>' },
    ['<Tab>'] = { shift = '<S-Tab>', control = '<C-Tab>', meta = nil },
    ['<Up>'] = { shift = '<S-Up>', control = '<C-Up>', meta = '<M-Up>' },
    ['<Down>'] = { shift = '<S-Down>', control = '<C-Down>', meta = '<M-Down>' },
    ['<Left>'] = { shift = '<S-Left>', control = '<C-Left>', meta = '<M-Left>' },
    ['<Right>'] = { shift = '<S-Right>', control = '<C-Right>', meta = '<M-Right>' },
    ['<F1>'] = { shift = '<S-F1>', control = '<C-F1>', meta = '<M-F1>' },
    ['<F2>'] = { shift = '<S-F2>', control = '<C-F2>', meta = '<M-F2>' },
    ['<F3>'] = { shift = '<S-F3>', control = '<C-F3>', meta = '<M-F3>' },
    ['<F4>'] = { shift = '<S-F4>', control = '<C-F4>', meta = '<M-F4>' },
    ['<F5>'] = { shift = '<S-F5>', control = '<C-F5>', meta = '<M-F5>' },
    ['<F6>'] = { shift = '<S-F6>', control = '<C-F6>', meta = '<M-F6>' },
    ['<F7>'] = { shift = '<S-F7>', control = '<C-F7>', meta = '<M-F7>' },
    ['<F8>'] = { shift = '<S-F8>', control = '<C-F8>', meta = '<M-F8>' },
    ['<F9>'] = { shift = '<S-F9>', control = '<C-F9>', meta = '<M-F9>' },
    ['<F10>'] = { shift = '<S-F10>', control = '<C-F10>', meta = '<M-F10>' },
    ['<F11>'] = { shift = '<S-F11>', control = '<C-F11>', meta = '<M-F11>' },
    ['<F12>'] = { shift = '<S-F12>', control = '<C-F12>', meta = '<M-F12>' },
    ['<Esc>'] = { shift = '<S-Esc>', control = '<C-Esc>', meta = '<M-Esc>' },
    -- TODO: add numpad, other nav cluster keys
  },

  global_key_presets = {
    uk = {
      ['`'] = { shift = '¬' },
      ['2'] = { shift = '"' },
      ['3'] = { shift = '£' },
      ["'"] = { shift = '@' },
      ['#'] = { shift = '~' },
    },
  },
}

---@type WhatKeyOptions
M.options = {}

---@param options? WhatKeyOptions
function M.setup(options)
  M.options = vim.tbl_deep_extend('force', {}, M.defaults, options or {})

  for k, v in pairs(M.options.highlights) do
    vim.api.nvim_set_hl(0, 'WhatKey' .. k, { link = v, default = true })
  end

  if M.options.global_key_presets[M.options.default_keyboard_layout] ~= nil then
    M.options.global_keys = vim.tbl_deep_extend(
      'force',
      M.options.global_keys,
      M.options.global_key_presets[M.options.default_keyboard_layout]
    )
  end
end

return M
