# what-key.nvim

**WhatKey** is a lua plugin for Neovim that displays a keyboard layout you can use to either browse your existing mappings or see _what key_ is available to be mapped!

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

This example has lazy loads by command and establishes keymaps, but those configs are optional:

```lua
{
  'bujesse/what-key.nvim',
  cmd = { 'WhatKeyToggle', 'WhatKeyShow' },
  keys = {
    { '<Leader>w', "<Cmd>lua require('what-key.view').toggle()<Cr>" },
  },
  opts = {},
}
```

Just make sure you are calling the setup function somewhere

```lua
require('what-key').setup()
```

## Configuration

### Usage

You can create a mapping to call the toggling of the WhatKey view.

```lua
vim.keymap.set('n', '<Leader>w', function()
  require('what-key.view').toggle()
end)
```

Alternatively, you can use the included commands:

`:WhatKeyShow` `:WhatKeyHide` `:WhatKeyToggle`

### Options

Options are force-merged with defaults:

```lua
{
  keymaps = {
    toggle_shift = '<Space>s',
    toggle_control = '<Space>c',
    enter_prefix = '<Space>p',
    change_mode = '<Space>m',
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
  },

  default_keyboard_layout = 'default',

  global_keys = {
    ['a'] = { shift = 'A', control = '<C-A>', meta = '<M-A>' },
    ['b'] = { shift = 'B', control = '<C-B>', meta = '<M-B>' },
    ['c'] = { shift = 'C', control = '<C-C>', meta = '<M-C>' },
    [' '] = { shift = '<S-Space>', control = '<C-Space>', meta = '<M-Space>' },
    [','] = { shift = '<lt>', control = '<C-,>', meta = '<M-,>' },
    ['.'] = { shift = '>', control = '<C-.>', meta = '<M-.>' },
    ['\\'] = { shift = '|', control = '<C-Bslash>', meta = '<M-Bslash>' },
    ['<CR>'] = { shift = '<S-CR>', control = '<C-CR>', meta = '<M-CR>' },
  },
}
```

#### NOTE: only a subset of the global keys are shown here. For the full list, see [the config](lua/what-key/config.lua)

#### How to configure

You can create keyboard layouts by passing them into `keyboard_layouts`. 
You may want to do this to support your own international or ergo layouts. Or even numpads.

Make sure to use the "base key" when creating layouts. The "base key" is the unique identifier used to look up its modifiers in the `global_keys` config. 

Using these 2 configs `keyboard_layouts` and `global_keys` should allow you to support any keyboard and key you want. Since there are so many keys and layouts in the world, a lot of them will not be supported out of the box.

If you feel that a layout or a global key should be supported by default, please add a request for it!

```lua
{
  keyboard_layouts = {
    hhkb = {
      { '<Esc>', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\\', '`'},
      { '<Tab>', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '<BS>' },
      { 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '<CR>' },
      { 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/' },
      { ' ' },
    },
  },
  default_keyboard_layout = 'hhkb',
  global_keys = {
    ['<Tab>'] = { shift = 'Q', control = '<C-A>', meta = '<M-A>' },
  },
}
```

In the example above, if you had a keyboard that for some reason had `<S-Tab>` mapped to `Q` on the actual keyboard, you could support that like this. So now if you toggle the `shift` key in the WhatKey window, you would see `Q` replace the `<Tab>` key.

