local config = require("agent-cli.config")

local snacks_available, Snacks = pcall(require, "snacks")
if not snacks_available then
  vim.notify("agent-cli.nvim: snacks.nvim is required", vim.log.levels.ERROR)
  return
end

local M = {}

---@class AgentCliTerminal
---@field id integer
---@field cmd string
---@field win snacks.win

---@type AgentCliTerminal[]
local terms = {}
local next_id = 1
local last = nil ---@type AgentCliTerminal? most recently used terminal

local positions = {
  { label = "Left", position = "left" },
  { label = "Right", position = "right" },
  { label = "Split bottom", position = "bottom" },
  { label = "Split top", position = "top" },
}

-- Terminals stay listed while their buffer lives, even if their window was hidden
local function prune()
  terms = vim.tbl_filter(function(t)
    return t.win:buf_valid()
  end, terms)
  if last and not last.win:buf_valid() then
    last = nil
  end
end

local function label(t)
  return string.format("%d: %s", t.id, t.cmd)
end

-- The terminal in the current window, otherwise the most recently used one
local function current()
  local buf = vim.api.nvim_get_current_buf()
  for _, t in ipairs(terms) do
    if t.win.buf == buf then
      return t
    end
  end
  return last or terms[#terms]
end

local function focus(t)
  if not t.win:win_valid() then
    t.win:show()
  end
  t.win:focus()
end

local function spawn(cmd, anchor, position)
  local id = next_id
  next_id = next_id + 1
  local opts = vim.deepcopy(config.opts.terminal)
  opts.count = id
  if anchor then
    if not anchor.win:win_valid() then
      anchor.win:show()
    end
    local vertical = position == "left" or position == "right"
    opts.win = vim.tbl_extend("force", opts.win or {}, {
      position = position,
      relative = "win",
      win = anchor.win.win,
      width = vertical and 0.5 or 0,
      height = vertical and 0 or 0.5,
      -- snacks equalizes every split sharing `relative` and `position`, which would
      -- resize side-by-side agent terminals; a unique tag opts this window out
      on_win = function(self)
        vim.w[self.win].snacks_win = vim.tbl_extend("force", vim.w[self.win].snacks_win or {}, {
          relative = "agent-cli-" .. id,
        })
      end,
    })
  end

  local t = { id = id, cmd = cmd } ---@type AgentCliTerminal
  t.win = Snacks.terminal.open(cmd, opts)
  t.win:on("BufEnter", function()
    last = t
  end, { buf = true })
  for lhs, rhs in pairs(config.opts.keys) do
    vim.keymap.set("t", lhs, rhs, { buffer = t.win.buf })
  end
  table.insert(terms, t)
  last = t
end

function M.open(cmd)
  local commands = config.opts.commands
  if not cmd and #commands > 1 then
    vim.ui.select(commands, { prompt = "Select agent CLI" }, function(choice)
      if choice then
        M.open(choice)
      end
    end)
    return
  end
  cmd = cmd or commands[1]

  prune()
  if #terms == 0 then
    spawn(cmd)
    return
  end

  -- Capture the anchor now; the picker may change the current window
  local anchor = current()
  vim.ui.select(positions, {
    prompt = string.format("Position relative to %s", label(anchor)),
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      spawn(cmd, anchor, choice.position)
    end
  end)
end

function M.close()
  for _, t in ipairs(terms) do
    t.win:close()
  end
  terms = {}
  last = nil
end

-- Sends `payload` to a terminal, asking which one when several are open
local function send(payload)
  prune()
  if #terms == 0 then
    vim.notify("agent-cli.nvim: no terminal opened", vim.log.levels.ERROR)
    return
  end

  local function deliver(t)
    vim.api.nvim_chan_send(vim.bo[t.win.buf].channel, payload)
    last = t
    if config.opts.focus_on_sel then
      focus(t)
    end
  end

  if #terms == 1 then
    deliver(terms[1])
    return
  end

  -- List the most recently used terminal first
  local items = vim.list_slice(terms)
  if last then
    table.sort(items, function(a, b)
      if (a == last) ~= (b == last) then
        return a == last
      end
      return a.id < b.id
    end)
  end
  vim.ui.select(items, { prompt = "Send to agent", format_item = label }, function(choice)
    if choice then
      deliver(choice)
    end
  end)
end

function M.send_file()
  local file_name = vim.fn.expand("%:.")
  send(string.format("@%s ", file_name))
end

function M.send_selection()
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

  -- Build the payload before a picker can leave visual mode
  send(string.format("@%s#L%s ", file_name, line_nums))
end

return M
