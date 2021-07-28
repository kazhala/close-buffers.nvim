local M = {}
local api = vim.api

--- Main function to delete all buffers
-- @param delete_type string: Types of buffer to delete.
-- @param delete_cmd string: Command to use to delete the buffer.
-- @param force boolean: Force deletion.
function M.close(delete_type, delete_cmd, force)
  vim.validate({
    type = { delete_type, 'string' },
    command = { delete_cmd, 'string' },
    force = { force, 'boolean' },
  })

  local buffers = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and api.nvim_buf_get_option(buf, 'buflisted')
  end, api.nvim_list_bufs())
  local bufnr = api.nvim_get_current_buf()

  --- Delete provided buffer
  -- @param buf int: Buffer number to delete.
  local function delete_buffer(buf)
    vim.cmd(delete_cmd .. ' ' .. buf)
  end

  --- Focus previous buffer
  -- @param buf int: Buffer number to switch focus.
  local function focus_prev_buffer(buf)
    if #buffers < 2 then
      return
    end

    local windows = vim.tbl_filter(function(win)
      return api.nvim_win_get_buf(win) == buf
    end, api.nvim_list_wins())

    if #windows == 0 then
      return
    end

    local prev_buffer_index = nil
    for index, buffer in ipairs(buffers) do
      if buffer == buf then
        prev_buffer_index = index - 1 > 0 and index - 1 or #buffers
        for _, win in ipairs(windows) do
          api.nvim_win_set_buf(win, buffers[prev_buffer_index])
        end
      end
    end
  end

  if delete_type == 'this' then
    focus_prev_buffer(bufnr)
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
      focus_prev_buffer(buffer)
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
