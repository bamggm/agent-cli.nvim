local config = require("pi.config")
local terminal = require("pi.terminal")
local M = {}

-- Register commands at module load time (not inside setup)
-- This ensures they're available when lazy.nvim loads the plugin
vim.api.nvim_create_user_command("PiOpen", function(opts)
  terminal.open(opts.args ~= "" and opts.args or nil)
end, { desc = "Open Pi", nargs = "?" })

vim.api.nvim_create_user_command("PiSendSel", function()
  terminal.send_selection()
end, { desc = "Pi visual select" })

vim.api.nvim_create_user_command("PiSendFile", function()
  terminal.send_file()
end, { desc = "Pi send file" })

function M.setup(opts)
  config.setup(opts)
end

return M
