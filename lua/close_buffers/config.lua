local M = {}

local config = {
  filetype_ignore = {},
  preserve_window_layout = { 'this', 'nameless' },
  next_buffer_cmd = nil,
}

local _config = {}

-- Get config details.
---@param key? string Config key to get, if not provided, all config is returned.
---@return table|function|nil All config details or specific keys.
function M.get(key)
  local target_config = next(_config) == nil and M.set({}) or _config

  if key then
    return target_config[key]
  end
  return target_config
end

-- Set config details.
---@param user_conf table Config to set.
---@return table Config details.
function M.set(user_conf)
  if user_conf and type(user_conf) == 'table' then
    config = vim.tbl_extend('force', config, user_conf)
  end
  for key, value in pairs(config) do
    if type(value) == 'table' then
      _config[key] = {}
    end

    if key == 'filetype_ignore' then
      for _, filetype in ipairs(config[key]) do
        _config[key][filetype] = true
      end
    elseif key == 'preserve_window_layout' then
      for _, delete_type in ipairs(config[key]) do
        _config[key][delete_type] = true
      end
    else
      _config[key] = value
    end
  end
  return _config
end

return M
