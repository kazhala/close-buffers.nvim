-- TODO: Add filetype as an argument, delete all filetypes

local M = {}
local api = vim.api
local config = require('close_buffers.config')

local allowed_delete_type = {
  nameless = true,
  other = true,
  hidden = true,
  all = true,
  this = true,
}

-- Match buffer name against glob or regex.
---@param bufnr number Buffer number to match.
---@param pattern table Table of parsed regex (vim.regex) and parsed glob (vim.glob2regpat).
---@return boolean Buffer name matches the pattern.
local function match_buffer_name(bufnr, pattern)
  local bufname = api.nvim_buf_get_name(bufnr)
  local glob = pattern.glob
  local regex = pattern.regex

  if glob then
    return vim.fn.matchstr(bufname, glob) ~= ''
  elseif regex then
    return regex:match_str(bufname) ~= nil
  end

  return true
end

-- Match buffer filetype against filetypes or config filetype_ignore.
---@param bufnr number Buffer number to match.
---@param filetype? string Filetype to match.
---@return boolean Buffer filetype matches the given filetype of one of the filetyp in config.
local function match_buffer_filetype(bufnr, filetype)
  if filetype ~= nil then
    return api.nvim_buf_get_option(bufnr, 'filetype') == filetype
  end

  return config.get('filetype_ignore')[api.nvim_buf_get_option(bufnr, 'filetype')] ~= nil
end

-- Focus next buffer and preserve window layout.
---@param bufnr number Buffer number to switch focus.
---@param delete_type string Types of deletion to perform.
local function preserve_window_layout(bufnr, delete_type)
  if not config.get('preserve_window_layout')[delete_type] then
    return
  end

  local all_windows = api.nvim_list_wins()
  local buffers = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and api.nvim_buf_get_option(buf, 'buflisted')
  end, api.nvim_list_bufs())

  if #buffers < 2 then
    local new_buf = api.nvim_create_buf(true, false)
    for _, win in ipairs(all_windows) do
      api.nvim_win_set_buf(win, new_buf)
    end
    return
  end

  if delete_type == 'all' then
    local new_buf = api.nvim_create_buf(true, false)
    for _, win in ipairs(all_windows) do
      api.nvim_win_set_buf(win, new_buf)
    end
    return
  end

  if delete_type == 'other' then
    for _, win in ipairs(all_windows) do
      api.nvim_win_set_buf(win, api.nvim_get_current_buf())
    end
    return
  end

  local windows = vim.tbl_filter(function(win)
    return api.nvim_win_get_buf(win) == bufnr
  end, all_windows)

  if #windows == 0 then
    return
  end

  local next_buffer_cmd = config.get('next_buffer_cmd')
  if next_buffer_cmd and type(next_buffer_cmd) == 'function' then
    next_buffer_cmd(windows)
  else
    for index, buffer in ipairs(buffers) do
      if buffer == bufnr then
        local new_focus_index = index + 1 > #buffers and #buffers - 1 or index + 1
        for _, win in ipairs(windows) do
          api.nvim_win_set_buf(win, buffers[new_focus_index])
        end
      end
    end
  end
end

-- Validate delete type
---@param delete_type string | number Types of buffer to delete
---@return boolean Is an allowed delete type
local function validate_delete_type(delete_type)
  return allowed_delete_type[delete_type] ~= nil or tonumber(delete_type) ~= nil
end

-- Main function to delete all buffers.
---@param delete_type string Types of buffer to delete.
---@param delete_cmd string Command to use to delete the buffer.
---@param force? boolean Force deletion.
---@param glob? string Filename pattern to match.
---@param regex? string Filename pattern.
function M.close(delete_type, delete_cmd, force, glob, regex)
  vim.validate({
    type = { delete_type, validate_delete_type },
    delete_cmd = { delete_cmd, 'string' },
    force = { force, 'boolean', true },
    glob = { glob, 'string', true },
    regex = { regex, 'string', true },
  })
  delete_cmd = force and delete_cmd .. '!' or delete_cmd
  local pattern = { glob = glob and vim.fn.glob2regpat(glob), regex = regex and vim.regex(regex) }

  if not validate_delete_type(delete_type) then
    return
  end

  -- Delete provided buffer.
  ---@param buf number Buffer number to delete.
  local function delete_buffer(buf)
    vim.cmd(delete_cmd .. ' ' .. buf)
  end

  -- Fileter buffer based on filetype, glob and regex
  ---@param buf number Buffer number to filter.
  ---@return boolean Buffer is valid or not.
  local function buffer_filter(buf)
    if not api.nvim_buf_is_valid(buf) or not api.nvim_buf_get_option(buf, 'buflisted') then
      return false
    end
    if glob or regex then
      return match_buffer_name(buf, pattern)
    else
      for _, ignore_regex in ipairs(config.get('file_regex_ignore')) do
        if match_buffer_name(buf, { regex = ignore_regex }) then
          return false
        end
      end
      for _, ignore_glob in ipairs(config.get('file_glob_ignore')) do
        if match_buffer_name(buf, { glob = ignore_glob }) then
          return false
        end
      end
    end
    if match_buffer_filetype(buf) then
      return false
    end
    return true
  end

  local buffers = vim.tbl_filter(buffer_filter, api.nvim_list_bufs())
  local bufnr

  if tonumber(delete_type) == nil then
    bufnr = api.nvim_get_current_buf()
  else
    bufnr = delete_type
    delete_type = 'this'
  end

  if delete_type == 'this' and buffer_filter(bufnr) then
    preserve_window_layout(bufnr, delete_type)
    delete_buffer(bufnr)
    return
  end

  local non_hidden_buffer = {}
  if delete_type == 'hidden' then
    for _, win in ipairs(api.nvim_list_wins()) do
      non_hidden_buffer[api.nvim_win_get_buf(win)] = true
    end
  end

  if delete_type == 'all' or delete_type == 'other' then
    preserve_window_layout(bufnr, delete_type)
  end

  for _, buffer in ipairs(buffers) do
    if api.nvim_buf_get_option(buffer, 'modified') and not force then
      api.nvim_err_writeln(
        string.format('No write since last change for buffer %d (set force to true to override)', buffer)
      )
    elseif delete_type == 'nameless' and api.nvim_buf_get_name(buffer) == '' then
      preserve_window_layout(buffer, delete_type)
      delete_buffer(buffer)
    elseif delete_type == 'other' and bufnr ~= buffer then
      delete_buffer(buffer)
    elseif delete_type == 'hidden' and non_hidden_buffer[buffer] == nil then
      delete_buffer(buffer)
    elseif delete_type == 'all' then
      delete_buffer(buffer)
    end
  end
end

return M
