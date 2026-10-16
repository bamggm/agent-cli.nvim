local M = {}

---Default configuration
---@class AgentCliConfig
---@field command string Pi CLI command (default: "pi")
---@field focus_on_sel boolean Focus terminal after sending selection (default: true)
---@field keys table<string, function|string> Buffer-local terminal mode keymaps applied only to agent-cli.nvim's terminal window (default: {})
---@field terminal SnacksTerminalOpts Snacks terminal options
local defaults = {
  command = "pi",
  keys = {},
  terminal = {
    interactive = true,
    win = {
      position = "right",
      width = 0.30,
      height = 0,
      relative = "editor",
    },
  },

  focus_on_sel = true,
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", defaults, opts or {})
  M.loaded = true
end

return M