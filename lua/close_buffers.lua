local M = {}
local buffers = require('close_buffers.buffers')

--- LUA bwipeout entry function
-- @param args table: User provided arguments.
function M.wipe(opts)
  buffers.close(opts.type, 'bwipeout', opts.force, opts.glob, opts.regex)
end

--- LUA bdelete entry function
-- @param args table: User provided arguments.
function M.delete(opts)
  buffers.close(opts.type, 'bdelete', opts.force, opts.glob, opts.regex)
end

--- VIM command entry function
-- @param delete_type string: Type of buffer to delete.
-- @param command string: lua function to invoke, either 'delete' or 'wipe'.
-- @param force string: Append bang to deletion command.
function M.cmd(delete_type, command, force)
  vim.validate({
    type = { delete_type, 'string' },
    command = { command, 'string' },
    force = { force, 'string', true },
  })

  local opts = {}
  opts.force = force == '!' and true or false
  opts.type = delete_type
  M[command](opts)
end

function M.setup(user_conf)
  require('close_buffers.config').set(user_conf)
end

return M
