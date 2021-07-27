local M = {}

function M.clear()
  for k, _ in pairs(package.loaded) do
    if string.match(k, '^close_buffers') then
      package.loaded[k] = nil
    end
  end
end

function M.close(opts)
  local allowed_delete_type = {
    nameless = true,
    other = true,
    hidden = true,
    all = true,
    this = true,
  }

  local delete_type = opts.delete_type
  if allowed_delete_type[delete_type] == nil then
    return
  end

  local delete_cmd = opts.delete_cmd
  if delete_cmd ~= 'bdelete' and delete_cmd ~= 'bwipeout' then
    delete_cmd = 'bdelete'
  end

  local force = opts.force or false
  if force == true then
    delete_cmd = delete_cmd .. '!'
  end

  local buffers = vim.fn.getbufinfo({ buflisted = true })
  local bufnr = vim.fn.bufnr('%')
  print(delete_type, force, delete_cmd)
  -- for _, value in pairs(buffers) do
  --   if bufnr ~= value.bufnr then
  --     print(vim.inspect(value))
  --     vim.cmd(delete_cmd ..)
  --   end
  -- end
end

return M
