# close-buffers.nvim

Lua port of [close-buffers.vim](https://github.com/Asheq/close-buffers.vim). This plugin allows you
to quickly delete multiple buffers based on condition provided.

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
  preserve_window_layout = { 'this', 'hidden' },  -- Types of deletion that should prserve the window layout
  next_buffer_cmd = nil,  -- Custom function to retrieve the next buffer when preserving window layout
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
  next_buffer_cmd = function()
    require('bufferline').cycle(1)
  end,
})

vim.api.nvim_set_keymap(
  'n',
  '<leader>th',
  [[<CMD>lua require('close_buffers').delete({type = 'hidden'})<CR>]],
  kb.silent_noremap
)
vim.api.nvim_set_keymap(
  'n',
  '<leader>tu',
  [[<CMD>lua require('close_buffers').delete({type = 'nameless'})<CR>]],
  kb.silent_noremap
)
```

## Usage

### Lua

```lua
-- bdelete
require('close_buffers').delete({type = 'hidden', force = true})
require('close_buffers').delete({type = 'nameless'})

-- bwipeout
require('close_buffers').wipe({type = 'all'})
require('close_buffers').wipe({type = 'other'})
```

### Vim

The plugin exposes 2 vim commands, `BDelete` and `BWipeout`. Each takes a single argument listed under the [options](#type) section.
To force a deletion, simply append the command with a bang.

```
:BDelete hidden
:BDelete! nameless
:BWipeout! all
```

## Options

### type

| type     | description                                                        |
| -------- | ------------------------------------------------------------------ |
| hidden   | Delete all listed buffers that's not visible in the current window |
| nameless | Delete all listed buffers without name                             |
| all      | Delete all listed buffers                                          |
| other    | Delete all listed buffers except the current focused buffer        |
| this     | Delete the current focused buffer                                  |

### force

Append a `bang` to the `bwipeout` or `bdelete` commands to force a deletion.
