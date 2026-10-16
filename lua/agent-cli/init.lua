local config = require("agent-cli.config")
local terminal = require("agent-cli.terminal")
local M = {}

-- Register commands at module load time (not inside setup)
-- This ensures they're available when lazy.nvim loads the plugin
vim.api.nvim_create_user_command("AgentOpen", function(opts)
  terminal.open(opts.args ~= "" and opts.args or nil)
end, { desc = "Open agent CLI", nargs = "?" })

vim.api.nvim_create_user_command("AgentSendSel", function()
  terminal.send_selection()
end, { desc = "Send visual selection to agent" })

vim.api.nvim_create_user_command("AgentSendFile", function()
  terminal.send_file()
end, { desc = "Send file to agent" })

function M.setup(opts)
  config.setup(opts)
end

return M
