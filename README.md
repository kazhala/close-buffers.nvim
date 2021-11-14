# close-buffers.nvim

Lua port of [close-buffers.vim](https://github.com/Asheq/close-buffers.vim) with several feature extensions. This plugin allows you
to quickly delete multiple buffers based on the [conditions](#options) provided.

![Demo](https://github.com/kazhala/gif/blob/master/close-buffers.gif)

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
require('close_buffers').setup({
  filetype_ignore = {},  -- Filetype to ignore when running deletions
  file_glob_ignore = {},  -- File name glob pattern to ignore when running deletions (e.g. '*.md')
  file_regex_ignore = {}, -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
  preserve_window_layout = { 'this', 'nameless' },  -- Types of deletion that should preserve the window layout
  next_buffer_cmd = nil,  -- Custom function to retrieve the next buffer when preserving window layout
})
```

### Example

By default, the `next_buffer_cmd` will attempt to get the next buffer by using the vim buffer ID.

This may not be as useful if you use bufferline plugins like [nvim-bufferline.lua](https://github.com/akinsho/nvim-bufferline.lua)
since you can rearrange the buffer orders ignoring the buffer ID. The following example will use the `cycle` command provided
by nvim-bufferline.lua to get the next buffer when preserving the window layout.

```lua
require('close_buffers').setup({
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
require('close_buffers').delete({ type = 'hidden', force = true }) -- Delete all non-visible buffers
require('close_buffers').delete({ type = 'nameless' }) -- Delete all buffers without name
require('close_buffers').delete({ type = 'this' }) -- Delete the current buffer
require('close_buffers').delete({ type = 1 }) -- Delete the specified buffer number
require('close_buffers').delete({ regex = '.*[.]md' }) -- Delete all buffers matching the regex

-- bwipeout
require('close_buffers').wipe({ type = 'all', force = true }) -- Wipe all buffers
require('close_buffers').wipe({ type = 'other' }) -- Wipe all buffers except the current focused
require('close_buffers').wipe({ type = 'hidden', glob = '*.lua' }) -- Wipe all buffers matching the glob
```

### Vim

The plugin exposes 2 vim commands, `BDelete` and `BWipeout`. Each takes a single argument listed under the [options](#type) section.
To force a deletion, simply append the command with a bang.

```
:BDelete! hidden
:BDelete nameless
:BDelete this
:BDelete 1
:BDelete regex='.*[.].md'

:BWipeout! all
:BWipeout other
:BWipeout hidden glob=*.lua
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

#### bufnr

> The bufnr would be one of the result from the vim `:ls` command.

You can also directly delete a buffer by providing buffer number as the [type](#type). The [type](#type) argument will automatically
change to `this` when specifying a buffer number as the [type](#type).

```lua
require('close_buffers').delete({ type = 1 }) -- Delete buffer with number 1
```

```
:BDelete 1
```

### force

Append a `bang` to the `bwipeout` or `bdelete` commands to force a deletion.

```lua
require('close_buffers').this({ type = 'this', force = true })
```

```
:BDelete! this
```

### regex

> Using this argument will take precedence over `file_regex_ignore` setting.

Delete buffers which matches the regex provided. When providing regex as an argument, the
`type` argument can be optional which will fallback to the value `all`.

```lua
require('close_buffers').delete({ regex = '.*[.]md', force = true }) -- Delete all markdown buffers
require('close_buffers').delete({ type = 'hidden', regex = '.*[.]lua' }) -- Delete all hidden lua buffers
```

```
:BDelete! regex=.*[.]md
:BDelete hidden regex=.*[.]lua
```

### glob

> Using this argument will take precedence over `file_glob_ignore` setting.

Similar to [regex](#regex), delete buffers which matches the glob pattern provided.
When providing glob as an argument, the `type` argument can be optional which will fallback to
the value `all`.

```lua
require('close_buffers').delete({ glob = '*.md', force = true }) -- Delele all markdown buffers
require('close_buffers').delete({ type = 'hidden', glob = '*.lua' }) -- Delete all hidden lua buffers
```

```
:BDelete! glob=*.md
:BDelete hidden glob=*.lua
```

## Credit

- [close-buffers.vim](https://github.com/Asheq/close-buffers.vim)
- [bufdelete.nvim](https://github.com/famiu/bufdelete.nvim)
