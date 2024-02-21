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

### Configuration
```lua
-- default values
{
  edit = {
    watch = false, -- Set true to automatically apply on save.
    force = false, -- Set true to force apply. Works only when watch = true.
  },
  notification = {
    on_open = true, -- vim.notify when start editing chezmoi-managed file.
    on_apply = true, -- vim.notify on apply.
    on_watch = false,
  },
}
```

### Treat all files in chezmoi source directory as chezmoi files
The below configuration wll allow you to automatically apply changes on files under chezmoi source path.
```lua
--  e.g. ~/.local/share/chezmoi/*
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
	callback = function()
    vim.schedule(require("chezmoi.commands.__edit").watch)
	end,
})
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
