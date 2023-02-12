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
}
```

### Others

You must call the setup function

```lua
require('what-key').setup()
```

## Configuration

You can create a mapping to call the toggling of the WhatKey view.

```lua
vim.keymap.set('n', '<Leader>w', function()
  require('what-key.view').toggle()
end)
```

Alternatively, you can just use the included commands:

`:WhatKeyShow` `:WhatKeyHide` `:WhatKeyToggle`

