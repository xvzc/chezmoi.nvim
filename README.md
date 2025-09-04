<div align="center">
  <h1 align="center">chezmoi.nvim</h2>
</div>
<br>
<div align="center">
  <p>Edit your chezmoi-managed files and automatically apply.</p>
  <img src="https://github.com/xvzc/chezmoi.nvim/assets/45588457/3053d4f9-a59c-4c29-b20c-b2c7a0e79a18" alt="chezmoi.nvim demo">
</div>

## What Is chezmoi.nvim?
`chezmoi.nvim` is a plugin designed to assist in editing and applying chezmoi-managed files within `neovim`. A notable distinction from the command line tool `chezmoi` is that `chezmoi.nvim` utilizes built-in neovim functions for file editing, allowing us to edit and watch multiple files simultaneously.

### Key Features
- **Bidirectional sync**: Edit source files and auto-apply to deployed locations, or edit deployed files and auto re-add to source
- **Multiple file handling**: Edit and watch multiple files simultaneously using neovim's built-in functions
- **Telescope integration**: Browse and select chezmoi-managed files with fuzzy finding
- **Flexible notifications**: Configurable notifications for all operations

## Getting Started
### Requirements
- [Neovim (v0.9.0)](https://github.com/neovim/neovim/releases/tag/v0.9.0) or the latest version
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [chezmoi](https://github.com/twpayne/chezmoi) latest version
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (optional)

### Installation

```lua
-- Lazy.nvim
{
  'xvzc/chezmoi.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require("chezmoi").setup {
      -- your configurations
    }
  end
},
```

### Configuration Options
```lua
{
  edit = {
    watch = false,
    force = false,
  },
  events = {
    on_open = {
      notification = {
        enable = true,
        msg = "Opened a chezmoi-managed file",
        opts = {},
      },
    },
    on_watch = {
      notification = {
        enable = true,
        msg = "This file will be automatically applied",
        opts = {},
      },
    },
    on_apply = {
      notification = {
        enable = true,
        msg = "Successfully applied",
        opts = {},
      },
    },
  },
  auto_readd = {
    enable = false,  -- Enable automatic re-add for managed files
    source_dir = nil,  -- Optional: custom chezmoi source directory
    watch_notification = {
      enable = true,
      msg = "chezmoi: watching %s for re-add",
      opts = {
        title = "chezmoi.nvim",
      },
    },
    notification = {
      enable = true,
      msg = "chezmoi: re-added %s to source",
      opts = {
        title = "chezmoi.nvim",
      },
    },
  },
  telescope = {
    select = { "<CR>" },
  },
}
```

### Automatically Running `chezmoi apply` In Specific Directories
The below configuration wll allow you to automatically apply changes on files under chezmoi source path.
```lua
--  e.g. ~/.local/share/chezmoi/*
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
    callback = function(ev)
        local bufnr = ev.buf
        local edit_watch = function()
            require("chezmoi.commands.__edit").watch(bufnr)
        end
        vim.schedule(edit_watch)
    end,
})
```

### Overriding Callback Functions
```lua

{
-- ...
  events = {
    on_open = {
      -- NOTE: This will override the default behavior of callback functions,
      -- including the invocation of notifications. If you want to override
      -- the default behavior but still show a notification on certain events,
      -- you should define the notification logic within your override function.
      override = function(bufnr)
        vim.notify("Opened a chezmoi-managed file")
      end,
    },
-- ...
}

```

## Auto Re-add

Automatically re-add managed files to chezmoi source when you save them. This feature allows you to edit deployed dotfiles directly (e.g., `~/.bashrc`) and have your changes automatically captured back to the chezmoi source directory.

### Why Use Auto Re-add?

When using chezmoi, you typically need to either:
1. Remember to use `chezmoi edit <file>` to edit the source version
2. Edit the deployed file and manually run `chezmoi re-add <file>` afterward

Auto re-add eliminates this friction by automatically detecting when you edit a chezmoi-managed file and running `re-add` on save.

### How It Works

1. When you open a file, the plugin checks if it's managed by chezmoi
2. If managed (and not already in the source directory), it sets up a `BufWritePost` autocmd
3. On save, it runs `chezmoi re-add <file>` to update the source
4. Shows notifications to confirm the action

### Basic Usage

Enable the feature in your configuration:

```lua
require("chezmoi").setup({
  auto_readd = {
    enable = true,
  },
})
```

Now when you edit any managed file:

```bash
nvim ~/.bashrc
# Shows: "chezmoi: watching ~/.bashrc for re-add"

# Make your changes and save
:w
# Shows: "chezmoi: re-added ~/.bashrc to source"
```

### Complete Bidirectional Workflow

For a seamless bidirectional workflow, enable both auto-apply and auto re-add:

```lua
require("chezmoi").setup({
  -- Auto-apply when editing source files
  edit = {
    watch = true,
    force = false,
  },
  -- Auto re-add when editing deployed files
  auto_readd = {
    enable = true,
  },
})
```

With this configuration:
- Edit `~/.local/share/chezmoi/dot_bashrc` → automatically applies to `~/.bashrc`
- Edit `~/.bashrc` → automatically re-adds to source
- You can edit either version and stay synchronized

### Telescope Integration
```lua
-- telscope-config.lua
local telescope = require("telescope")

telescope.setup {
  -- ... your telescope config
}

telescope.load_extension('chezmoi')
vim.keymap.set('n', '<leader>cz', telescope.extensions.chezmoi.find_files, {})

-- You can also search a specific target directory and override arguments
-- Here is an example with the default args
vim.keymap.set('n', '<leader>fc', function()
  telescope.extensions.chezmoi.find_files({
    targets = vim.fn.stdpath("config"),
    -- This overrides the default arguments used with 'chezmoi list'
    args = { 
      "--path-style",
      "absolute",
      "--include",
      "files",
      "--exclude",
      "externals",
    }
  })
end, {})
```

## User Commands
```vim
:ChezmoiEdit <target> <args>
" This will open '~/.local/chezmoi/dot_zshrc' and apply the changes on save
" :ChezmoiEdit ~/.zshrc --watch
" Arguments
" --watch Automatically apply changes on save
" --force force apply.

:ChezmoiList <args>
" :ChezmoiList --include=files
" You can put any of command line arguments of 'chezmoi' here
```

## API
See [Commands](https://github.com/xvzc/chezmoi.nvim/blob/main/lua/chezmoi/commands/init.lua) for more information
### List
```lua
local managed_files = require("chezmoi.commands").list()
print(vim.inspect(managed_files))
```

### Edit
```lua
-- NOTE: chezmoi.nvim utilizes builtin neovim functions for file editing instead of `chzmoi edit`
require("chezmoi.commands").edit({
    targets = { "~/.zshrc" },
    args = { "--watch" }
})
```
