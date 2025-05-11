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
  telescope = {
    select = { "<CR>" },
  },
}
```

### Treat all files in chezmoi source directory as chezmoi files
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

### Overriding callback functions running on events
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

### fzf-lua Integration
```lua
fzf_chezmoi = function()
  require'fzf-lua'.fzf_exec(require("chezmoi.commands").list(), {
    actions = {
      ['default'] = function(selected, opts)
	require("chezmoi.commands").edit({
	  targets = {"~/" .. selected[1]},
	  args = { "--watch" }
	})
      end
    }
  })
end

vim.api.nvim_command('command! ChezmoiFzf lua fzf_chezmoi()')
```

## User Command
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
