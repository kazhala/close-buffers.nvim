local M = {}

local allowed_delete_type = {
  nameless = true,
  other = true,
  hidden = true,
  all = true,
  this = true,
}

-- argument parser
local function get_opts(opts)
  local result = {}
  result.delete_type = opts.type
  result.delete_cmd = opts.delete_cmd
  result.force = opts.force

  if allowed_delete_type[result.delete_type] == nil then
    return
  end
  if result.force == true then
    result.delete_cmd = result.delete_cmd .. '!'
  end

  return result
end

-- main function to delete all buffers
local function close_buffers(opts)
  local buffers = vim.fn.getbufinfo({ buflisted = true })
  local bufnr = vim.fn.bufnr('%')

  local function delete_buffer(buf)
    vim.cmd(opts.delete_cmd .. ' ' .. buf)
  end

  if opts.delete_type == 'this' then
    delete_buffer(bufnr)
    return
  end

  for _, buffer in pairs(buffers) do
    if buffer.changed ~= 0 and not opts.force then
      vim.api.nvim_err_writeln(
        string.format('No write since last change for buffer %d (set force to true to override)', buffer.bufnr)
      )
    elseif opts.delete_type == 'nameless' and buffer.name == '' then
      delete_buffer(buffer.bufnr)
    elseif opts.delete_type == 'other' and bufnr ~= buffer.bufnr then
      delete_buffer(buffer.bufnr)
    elseif opts.delete_type == 'hidden' and buffer.hidden ~= 0 then
      delete_buffer(buffer.bufnr)
    elseif opts.delete_type == 'all' then
      delete_buffer(buffer.bufnr)
    end
  end
end

-- lua wipe entry function
function M.wipe(args)
  args.delete_cmd = 'bwipeout'
  local opts = get_opts(args)
  if opts == nil then
    return
  end
  close_buffers(opts)
end

-- lua delete entry function
function M.delete(args)
  args.delete_cmd = 'bdelete'
  local opts = get_opts(args)
  if opts == nil then
    return
  end
  close_buffers(opts)
end

-- vim script command entry function
function M.cmd(type, command, force)
  vim.validate({
    type = { type, 'string' },
    command = { command, 'string' },
    force = { force, 'string', true },
  })

  if allowed_delete_type[type] == nil then
    return
  end

  local opts = {}
  opts.force = force == '!' and true or false
  opts.type = type
  M[command](opts)
end

return M
