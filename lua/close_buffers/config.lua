local M = {}

local config = {
  filetype_ignore = {},
  preserve_window_layout = { 'this', 'hidden' },
}

function M.get(key)
  if key then
    return config[key]
  end
  return config
end

function M.set(user_conf)
  if user_conf and type(user_conf) == 'table' then
    config = vim.tbl_extend('force', config, user_conf)
  end
  return config
end

return M
