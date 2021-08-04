local M = {}
local buffers = require('close_buffers.buffers')

local function check_pattern(opts)
  if not opts.type and (opts.glob or opts.regex) then
    opts.type = 'all'
  end
  return opts
end

-- LUA bwipeout entry function.
---@param opts table User provided arguments.
function M.wipe(opts)
  opts = check_pattern(opts)
  buffers.close(opts.type, 'bwipeout', opts.force, opts.glob, opts.regex)
end

-- LUA bdelete entry function.
---@param opts table User provided arguments.
function M.delete(opts)
  opts = check_pattern(opts)
  buffers.close(opts.type, 'bdelete', opts.force, opts.glob, opts.regex)
end

-- VIM command entry function.
---@param args string Command line arguments.
---@param command string The lua function to invoke, either 'delete' or 'wipe'.
---@param force? string Append bang to deletion command.
function M.cmd(args, command, force)
  vim.validate({
    args = { args, 'string' },
    command = { command, 'string' },
    force = { force, 'string', true },
  })

  local opts = {}
  opts.force = force == '!' and true or false

  for _, value in ipairs(vim.split(args, ' ')) do
    if string.match(value, 'glob=') then
      opts.glob = string.sub(value, 6)
    elseif string.match(value, 'regex=') then
      opts.regex = string.sub(value, 7)
    else
      opts.type = value
    end
  end

  M[command](opts)
end

-- Configure close_buffers options.
---@param user_conf table
function M.setup(user_conf)
  require('close_buffers.config').set(user_conf)
end

return M
