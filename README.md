# close-buffers.nvim

Lua port of [close-buffers.vim](https://github.com/Asheq/close-buffers.vim) with a few [feature extensions](#configuration). This plugin allows you
to quickly delete multiple buffers based on the [condition](#type) provided.

![Demo](https://assets.kazhala.me/close-buffers/demo.gif)

## Requirements

```
Neovim >= 0.5
```

## Installation

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```
use 'kazhala/close-buffers.nvim'
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```
plug 'kazhala/close-buffers.nvim'
```

## Configuration

```lua
require('close-buffers').setup({
  filetype_ignore = {},  -- Filetype to ignore when running deletions
  preserve_window_layout = { 'this', 'hidden' },  -- Types of deletion that should preserve the window layout
  next_buffer_cmd = function(windows) end,  -- Custom function to retrieve the next buffer when preserving window layout
})
```

### Example

By default, the `next_buffer_cmd` will attempt to get the next buffer by using the vim buffer ID.

This may not be as useful if you use bufferline plugins like [nvim-bufferline.lua](https://github.com/akinsho/nvim-bufferline.lua)
since you can rearrange the buffer orders ignoring the buffer ID. The following example will use the `cycle` command provided
by nvim-bufferline.lua to get the next buffer when preserving the window layout.

```lua
require('close-buffers').setup({
  preserve_window_layout = { 'this' },
  next_buffer_cmd = function(windows)
    require('bufferline').cycle(1)
    local bufnr = vim.api.nvim_get_current_buf()

    for _, window in ipairs(windows) do
      vim.api.nvim_win_set_buf(window, bufnr)
    end
  end,
})

vim.api.nvim_set_keymap(
  'n',
  '<leader>th',
  [[<CMD>lua require('close_buffers').delete({type = 'hidden'})<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  'n',
  '<leader>tu',
  [[<CMD>lua require('close_buffers').delete({type = 'nameless'})<CR>]],
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  'n',
  '<leader>tc',
  [[<CMD>lua require('close_buffers').delete({type = 'this'})<CR>]],
  { noremap = true, silent = true }
)
```

## Usage

### Lua

```lua
-- bdelete
require('close_buffers').delete({type = 'hidden', force = true})
require('close_buffers').delete({type = 'nameless'})
require('close_buffers').delete({type = 'this'})

-- bwipeout
require('close_buffers').wipe({type = 'all', force = true})
require('close_buffers').wipe({type = 'other'})
```

### Vim

The plugin exposes 2 vim commands, `BDelete` and `BWipeout`. Each takes a single argument listed under the [options](#type) section.
To force a deletion, simply append the command with a bang.

```
:BDelete hidden
:BDelete! nameless
:BWipeout! all
:BDelete other
:BDelete! this
```

## Options

### type

| type         | description                                                          |
| ------------ | -------------------------------------------------------------------- |
| **hidden**   | Delete all listed buffers that's not visible in the current window   |
| **nameless** | Delete all listed buffers without name                               |
| **this**     | Delete the current focused buffer without changing the window layout |
| all          | Delete all listed buffers                                            |
| other        | Delete all listed buffers except the current focused buffer          |

### force

Append a `bang` to the `bwipeout` or `bdelete` commands to force a deletion.

## Credit

- [close-buffers.vim](https://github.com/Asheq/close-buffers.vim)
- [bufdelete.nvim](https://github.com/famiu/bufdelete.nvim)
