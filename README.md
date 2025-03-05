# what-key.nvim

**WhatKey** is a lua plugin for Neovim that displays a keyboard layout you can use to either browse your existing mappings or see _what key_ is available to be mapped!

![image](https://github.com/user-attachments/assets/617d4ad4-a8c4-4112-a106-1329149ce8cd)

### Motivation

In order to find a home for a new mapping, I typically have some sort of thought process like this:

1. I want to find a home for a new `git`-related keymap. I would want it to be phonetic; `git` commands should go under some mapping that has `g` in it.
2. What commands do I already have under that prefix? I know that `g` is used as a prefix for some built in vim commands, but I can't remember which ones are free; or even which ones I already have a mapping for.
3. What other options do I have? What about `G`? What about `<C-g>`? And `<Leader>g` or `<Space>g` or `<Leader>G`? There are a lot of ways I can get to a `g`-ish character, but I have no idea what other mappings are there or if I would accidentally write over something else.

There are a lot of decisions that have to be made in order to find a reasonable home for a new keymap. That's where **WhatKey** helps. **WhatKey** solves a different problem than other KeyBinding plugins such as the great [which-key](https://github.com/folke/which-key.nvim), which helps you to _remember_ what keymaps you already have. **WhatKey** provides the user with the full keyboard layout so they can visually find where mappings live or don't live; much like a keymap browser.

Other use cases for **WhatKey** include:

* Cleaning up unused keymaps; being able to browse the full keymap lets me see where unused maps might be living by telling me how many mappings live under a certain prefix.
* Learning about vim built-in mappings, and making sure I don't create a mapping that would overwrite a useful one. Sometimes picking a "free" key is about finding one that doesn't already have a useful vim function.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

This example has lazy loads by command and establishes a toggling keymap, but those configs are optional:

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

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "bujesse/what-key.nvim",
  cmd = { 'WhatKeyToggle', 'WhatKeyShow' },
  config = function()
    require('what-key').setup({})
  end
})
```

Just make sure you are calling the setup function somewhere

```lua
require('what-key').setup({})
```

## Configuration

### Usage

You can create a mapping to call the toggling of the **WhatKey** view.

```lua
vim.keymap.set('n', '<Leader>w', function()
  require('what-key.view').toggle()
end)
```

Alternatively, you can use the included commands:

`:WhatKeyShow` `:WhatKeyHide` `:WhatKeyToggle`

Inside the WhatKey window, there are a few commands available shown at the bottom. These are local to the WhatKey window, and can be configured. 

A useful mapping is using `<Enter>` and `<Backspace>` to navigate "in" and "out" of a prefix. So if you were to hit `<Enter>` on the `<Space>` key, you would now be looking at mappings that _start_ with `<Space>`.

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

#### NOTE: only a subset of the layouts and global keys are shown here. For the full set of those, see [the config](lua/what-key/config.lua)

### Configuring your own layouts and keys

You can create keyboard layouts by passing them into `keyboard_layouts`. 
You may want to do this to support your own international or ergo layout.

Make sure to use the "base key" when creating layouts. The "base key" is the unique identifier used to look up its modifiers in the `global_keys` config. It would typically represent what key would be pressed if you had no modifiers held (no shift, ctrl, etc).

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
    ['3'] = { shift = '§' },
  },
}
```

In the example above, by adding `['3']` to the `global_keys` table, you can override what key will be shown when the `shift` modifier is active. Notice you do not have to describe all mods, as missing ones will be inferred as `<S-...>`, `<C-...>`, etc.

To take that a step further, you can define sets of these overrides using `global_key_presets`. Some of them like `uk` are already defined and are applied automatically if a key in the `global_key_presets` matches the currently selected layout. 

So for instance, if you set `default_keyboard_layout` to `'uk'`, the `global_key_presets.uk` would be automatically applied. See [the config](lua/what-key/config.lua) for an example on how to define your own.

