local M = {}
local api = vim.api
local config = require('close_buffers.config')

local allowed_delete_type = {
  nameless = true,
  other = true,
  hidden = true,
  all = true,
  this = true,
  -- glob = true,
}

--- Main function to delete all buffers
-- @param delete_type string: Types of buffer to delete.
-- @param delete_cmd string: Command to use to delete the buffer.
-- @param force boolean: Force deletion.
function M.close(delete_type, delete_cmd, force)
  vim.validate({
    type = { delete_type, 'string' },
    command = { delete_cmd, 'string' },
    force = { force, 'boolean', true },
  })

  if allowed_delete_type[delete_type] == nil then
    return
  end

  local buffers = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and api.nvim_buf_get_option(buf, 'buflisted')
  end, api.nvim_list_bufs())
  local bufnr = api.nvim_get_current_buf()

  --- Delete provided buffer
  -- @param buf int: Buffer number to delete.
  local function delete_buffer(buf)
    if config.get('filetype_ignore')[api.nvim_buf_get_option(buf, 'filetype')] then
      return
    end
    vim.cmd(delete_cmd .. ' ' .. buf)
  end

  --- Focus next buffer and preserve window layout
  -- @param buf int: Buffer number to switch focus.
  -- @param del_type string: Types of deletion to perform.
  local function preserve_window_layout(buf, del_type)
    if not config.get('preserve_window_layout')[del_type] then
      return
    end

    if #buffers < 2 then
      return
    end

    local windows = vim.tbl_filter(function(win)
      return api.nvim_win_get_buf(win) == buf
    end, api.nvim_list_wins())

    if #windows == 0 then
      return
    end

    if del_type == 'other' then
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
        if buffer == buf then
          local new_focus_index = index + 1 > #buffers and #buffers or index + 1
          for _, win in ipairs(windows) do
            api.nvim_win_set_buf(win, buffers[new_focus_index])
          end
        end
      end
    end
  end

  if delete_type == 'this' then
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

  for _, buffer in ipairs(buffers) do
    if api.nvim_buf_get_option(buffer, 'modified') and not force then
      api.nvim_err_writeln(
        string.format('No write since last change for buffer %d (set force to true to override)', buffer)
      )
    elseif delete_type == 'nameless' and api.nvim_buf_get_name(buffer) == '' then
      preserve_window_layout(buffer, delete_type)
      delete_buffer(buffer)
    elseif delete_type == 'other' and bufnr ~= buffer then
      preserve_window_layout(buffer, delete_type)
      delete_buffer(buffer)
    elseif delete_type == 'hidden' and non_hidden_buffer[buffer] == nil then
      delete_buffer(buffer)
    elseif delete_type == 'all' then
      delete_buffer(buffer)
    end
  end
end

return M
