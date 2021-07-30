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

--- Match buffer name against glob or regex
-- @param bufnr number: Buffer number to match.
-- @param pattern table: Table of regex and glob patterns.
-- @return boolean: buffername matches the pattern.
local function match_buffer_name(bufnr, pattern)
  local bufname = api.nvim_buf_get_name(bufnr)
  local glob = pattern.glob
  local regex = pattern.regex

  if glob then
    return vim.fn.matchstr(bufname, vim.fn.glob2regpat(glob)) ~= ''
  elseif regex then
    return vim.regex(regex):match_str(bufname) ~= nil
  end

  return true
end

--- Focus next buffer and preserve window layout
-- @param bufnr number: Buffer number to switch focus.
-- @param buffers table: List of available buffers.
-- @param delete_type string: Types of deletion to perform.
local function preserve_window_layout(bufnr, buffers, delete_type)
  if not config.get('preserve_window_layout')[delete_type] then
    return
  end

  if #buffers < 2 then
    return
  end

  local windows = vim.tbl_filter(function(win)
    return api.nvim_win_get_buf(win) == bufnr
  end, api.nvim_list_wins())

  if #windows == 0 then
    return
  end

  if delete_type == 'other' then
    for _, win in ipairs(windows) do
      api.nvim_win_set_buf(win, bufnr)
    end
    return
  end

  local next_buffer_cmd = config.get('next_buffer_cmd')
  if next_buffer_cmd and type(next_buffer_cmd) == 'function' then
    next_buffer_cmd(windows)
  else
    for index, buffer in ipairs(buffers) do
      if buffer == bufnr then
        local new_focus_index = index + 1 > #buffers and #buffers or index + 1
        for _, win in ipairs(windows) do
          api.nvim_win_set_buf(win, buffers[new_focus_index])
        end
      end
    end
  end
end

--- Main function to delete all buffers
-- @param delete_type string: Types of buffer to delete.
-- @param delete_cmd string: Command to use to delete the buffer.
-- @param force boolean: Force deletion.
-- @param glob string: Filename pattern to match.
-- @param regex string: Filename pattern
function M.close(delete_type, delete_cmd, force, glob, regex)
  vim.validate({
    type = { delete_type, 'string' },
    delete_cmd = { delete_cmd, 'string' },
    force = { force, 'boolean', true },
    glob = { glob, 'string', true },
    regex = { regex, 'string', true },
  })
  delete_cmd = force and delete_cmd .. '!' or delete_cmd
  local pattern = { glob = glob, regex = regex }

  if allowed_delete_type[delete_type] == nil then
    return
  end

  local buffers = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and api.nvim_buf_get_option(buf, 'buflisted') and match_buffer_name(buf, pattern)
  end, api.nvim_list_bufs())
  local bufnr = api.nvim_get_current_buf()

  --- Delete provided buffer
  -- @param buf number: Buffer number to delete.
  local function delete_buffer(buf)
    if config.get('filetype_ignore')[api.nvim_buf_get_option(buf, 'filetype')] then
      return
    end
    vim.cmd(delete_cmd .. ' ' .. buf)
  end

  if delete_type == 'this' and match_buffer_name(bufnr, pattern) then
    preserve_window_layout(bufnr, buffers, delete_type)
    delete_buffer(bufnr)
  end

  local non_hidden_buffer = {}
  if delete_type == 'hidden' then
    for _, win in ipairs(api.nvim_list_wins()) do
      non_hidden_buffer[api.nvim_win_get_buf(win)] = true
    end
  end

  for _, buffer in ipairs(buffers) do
    if api.nvim_buf_get_option(buffer, 'modified') and not force then
      api.nvim_err_writeln(
        string.format('No write since last change for buffer %d (set force to true to override)', buffer)
      )
    elseif delete_type == 'nameless' and api.nvim_buf_get_name(buffer) == '' then
      preserve_window_layout(bufnr, buffers, delete_type)
      delete_buffer(buffer)
    elseif delete_type == 'other' and bufnr ~= buffer then
      preserve_window_layout(bufnr, buffers, delete_type)
      delete_buffer(buffer)
    elseif delete_type == 'hidden' and non_hidden_buffer[buffer] == nil then
      delete_buffer(buffer)
    elseif delete_type == 'all' then
      delete_buffer(buffer)
    end
  end
end

return M
