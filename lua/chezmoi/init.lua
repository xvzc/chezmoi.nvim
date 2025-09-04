local chezmoi = {}

local default_config = {
  extra_args = {},
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
    enable = false,
    source_dir = nil,
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

function chezmoi.setup(opts)
  local config = vim.tbl_deep_extend("force", default_config, opts)
  chezmoi.config = config
  vim.g.chezmoi_setup = 1
  
  -- Setup auto re-add functionality if enabled
  local auto_readd = require("chezmoi.auto_readd")
  auto_readd.setup(config)
end

function chezmoi.get_config()
  return chezmoi.config or default_config
end

if vim.g.chezmoi_setup ~= 1 then
  chezmoi.config = default_config
end

return chezmoi
