# agent-cli.nvim

A minimal Neovim plugin that integrates [Pi Agent](https://github.com/bamggm/pi.nvim) as an interactive terminal powered by [snacks.nvim](https://github.com/folke/snacks.nvim).

## Features

- **Interactive Terminal** - Open Pi Agent directly in Neovim
- **Send Visual Selections** - Select code in visual mode and send it to Pi Agent with file context (e.g., `@lua/agent-cli/init.lua#L1-15`)
- **Send File Context** - In normal mode, send the current file reference to Pi Agent (e.g., `@lua/agent-cli/init.lua`)

## Demo

https://github.com/user-attachments/assets/f499f960-6188-413b-a57f-0271b75556d5

## Requirements

- Neovim >= 0.10 (required by snacks.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)
- [Pi Agent](https://github.com/bamggm/pi.nvim) CLI (`pi` command)

## Installation

### lazy.nvim

```lua
{
  "bamggm/agent-cli.nvim",
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { "<leader>ap", "<cmd>AgentSendFile<CR>", desc = "Send file to Pi Agent" },
    { "<leader>ap", "<cmd>AgentSendSel<CR>", mode = "v", desc = "Send selection to Pi Agent" },
    { "<leader>ao", "<cmd>AgentOpen<CR>", desc = "Open Pi Agent" },
  },
}
```

#### Tmux Users (Optional)
Use agent-cli.nvim's `keys` option to set terminal keymaps (scoped to the snacks terminal window only):

```lua
{
  "bamggm/agent-cli.nvim",
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { "<leader>ap", "<cmd>AgentSendFile<CR>", desc = "Send file to Pi Agent" },
    { "<leader>ap", "<cmd>AgentSendSel<CR>", mode = "v", desc = "Send selection to Pi Agent" },
    { "<leader>ao", "<cmd>AgentOpen<CR>", desc = "Open Pi Agent" },
  },
  opts = {
    keys = {
      ["<C-h>"] = "<Cmd>NvimTmuxNavigateLeft<CR>",
      ["<C-j>"] = "<Cmd>NvimTmuxNavigateDown<CR>",
      ["<C-k>"] = "<Cmd>NvimTmuxNavigateUp<CR>",
      ["<C-l>"] = "<Cmd>NvimTmuxNavigateRight<CR>",
    },
  },
}
```

## Configuration

```lua
require("agent-cli").setup({
  command = "pi",           -- Pi CLI command
  focus_on_sel = true,      -- Focus terminal after sending selection
  keys = {},                -- Buffer-local terminal mode keymaps

  -- snacks terminal options
  terminal = {
    interactive = true,
    win = {
      position = "right",
      width = 0.30,
      height = 0,
      relative = "editor",
    },
  },
})
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `command` | string | `"pi"` | Pi CLI command |
| `focus_on_sel` | boolean | `true` | Focus terminal after sending selection |
| `keys` | table | `{}` | Buffer-local terminal mode keymaps (e.g. `{ ["<C-h>"] = fn }`) |
| `terminal` | table | (see above) | snacks terminal options |

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:AgentOpen` | Open Pi Agent in a terminal window |
| `:AgentSendSel` | Send visual selection to Pi Agent |
| `:AgentSendFile` | Send current file reference to Pi Agent (normal mode) |

### Sending Code to Pi Agent

1. Select code in visual mode (`v`, `V`, or `Ctrl+v`)
2. Press `<leader>ap`
3. The selection is sent with file and line context
4. Interact with Pi Agent in the terminal

### Sending File Context to Pi Agent

1. In normal mode, press `<leader>ap`
2. The current file reference is sent (e.g., `@lua/agent-cli/init.lua`)
3. Interact with Pi Agent in the terminal

## FAQ

- `pi` is an external process to Neovim so editor buffer is not refreshed and can conflict
if you have unmodified changes. You can use `:e!` (`:help edit!`) to reopen the file
_discarding_ any unmodified changes.

## How it works

- Uses the `folke/snacks` terminal module and launch `pi` process. That's all. Nothing fancy.

## Alternative

Consider other options to use Pi agent along with Neovim:

- [pablopunk/pi.nvim](https://github.com/pablopunk/pi.nvim)

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.
