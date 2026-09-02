local config = require("pi.config")

local snacks_available, Snacks = pcall(require, "snacks")
if not snacks_available then
  vim.notify("pi.nvim: snacks.nvim is required", vim.log.levels.ERROR)
  return
end

local M = {}
local term = nil -- window

function M.open(cmd)
  if term ~= nil and term:valid() then
    term:focus()
    return
  end
  term = Snacks.terminal.open(cmd or config.opts.command, config.opts.terminal)
  for lhs, rhs in pairs(config.opts.keys) do
    vim.keymap.set("t", lhs, rhs, { buffer = term.buf })
  end
end

function M.close()
  if term ~= nil and term:valid() then
    term:close()
    term = nil
  end
end

function M.send_file()
  if term == nil or not term:valid() then
    vim.notify("pi.nvim: no terminal opened", vim.log.levels.ERROR)
    return
  end

  local file_name = vim.fn.expand("%:.")
  local payload = string.format("@%s ", file_name)

  local chan_id = vim.bo[term.buf].channel
  vim.api.nvim_chan_send(chan_id, payload)

  if config.opts.focus_on_sel then
    term:focus()
  end
end

function M.send_selection()
  if term == nil or not term:valid() then
    vim.notify("pi.nvim: no terminal opened", vim.log.levels.ERROR)
    return
  end

  local file_name = vim.fn.expand("%:.")

  -- 'v' gets the line where visual selection started
  local v_start = vim.fn.line("v")

  -- '.' gets the current cursor line
  local cursor_pos = vim.fn.line(".")

  -- The user might select upwards, so we must calculate the min and max
  local start_line = math.min(v_start, cursor_pos)
  local end_line = math.max(v_start, cursor_pos)

  -- Construct the payload matching: @<path>#L<start>-<end>
  local line_nums
  if start_line == end_line then
    line_nums = string.format("%d", start_line)
  else
    line_nums = string.format("%d-%d", start_line, end_line)
  end
  --
  local payload = string.format("@%s#L%s ", file_name, line_nums)

  -- 5. Transmit to the terminal channel without a carriage return
  local chan_id = vim.bo[term.buf].channel
  vim.api.nvim_chan_send(chan_id, payload)

  if config.opts.focus_on_sel then
    term:focus()
  end
end

return M
