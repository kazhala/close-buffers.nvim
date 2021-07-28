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

## Usage

```lua
-- bdelete
require('close_buffers').delete({type = 'hidden', force = true})
require('close_buffers').delete({type = 'nameless'})

-- bwipeout
require('close_buffers').wipe({type = 'all'})
require('close_buffers').wipe({type = 'other'})
```

## Options

### type

| type     | description                                                       |
| -------- | ----------------------------------------------------------------- |
| hidden   | Delete all listed buffers thats not visible in the current window |
| nameless | Delete all listed buffers without name                            |
| all      | Delete all listed buffers                                         |
| other    | Delete all listed buffers except the current focused buffer       |
| this     | Delete the current focused buffer                                 |

### force

Append a `bang` to the `bwipeout` or `bdelete` commands to force a deletion.
