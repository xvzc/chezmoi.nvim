<div align="center">
  <h1 align="center">chezmoi.nvim</h2>
</div>
<br>
<div align="center">
  <p>Edit your chezmoi-managed files and automatically apply.</p>
  <img src="https://github.com/xvzc/chezmoi.nvim/assets/45588457/3053d4f9-a59c-4c29-b20c-b2c7a0e79a18" alt="chezmoi.nvim demo" height="500px">
</div>

## What Is chezmoi.nvim?
`chezmoi.nvim` is a plugin that can help you with editing or applying chezmoi-managed files on neovim.

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
    require("chezmoi").setup {}
  end
},
```

### Configuration
```lua
-- default values
{
  watch_on_edit = false,
  notification = {
    on_open = true,
    on_save = true
  },
}

```
