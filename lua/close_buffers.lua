local M = {}
local buffers = require('close_buffers.buffers')

--- Argument parser function
-- @param opts table: Table of options to parse.
-- @return table: Table of parsed options.
local function get_opts(opts)
  local result = {}
  result.delete_type = opts.type
  result.delete_cmd = opts.delete_cmd
  result.force = opts.force

  if result.force == true then
    result.delete_cmd = result.delete_cmd .. '!'
  end

  return result
end

--- LUA bwipeout entry function
-- @param args table: User provided arguments.
function M.wipe(args)
  args.delete_cmd = 'bwipeout'
  local opts = get_opts(args)
  if opts == nil then
    return
  end
  buffers.close(opts.delete_type, opts.delete_cmd, opts.force)
end

--- LUA bdelete entry function
-- @param args table: User provided arguments.
function M.delete(args)
  args.delete_cmd = 'bdelete'
  local opts = get_opts(args)
  if opts == nil then
    return
  end
  buffers.close(opts.delete_type, opts.delete_cmd, opts.force)
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
