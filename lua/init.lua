local M = {}

local default_config = {
  edit = {
    watch = false,
    force = false,
  },
  events = {
    on_watch = {
      notification = {
        enable = true,
        msg = "chezmoi: watch started",
        opts = {
          title = "chezmoi.nvim",
        },
      },
      override = nil,
    },
    on_apply = {
      notification = {
        enable = true,
        msg = "chezmoi: applied",
        opts = {
          title = "chezmoi.nvim",
        },
      },
      override = nil,
    },
    on_open = {
      notification = {
        enable = true,
        msg = "chezmoi: editing source file",
        opts = {
          title = "chezmoi.nvim",
        },
      },
      override = nil,
    },
  },
  -- NEW: Auto re-add configuration
  auto_readd = {
    enable = false,
    source_dir = nil,  -- defaults to ~/.local/share/chezmoi
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
  notification = {
    backend = "notify",
  },
  telescope = {
    select = {
      keybindings = {
        edit = "<CR>",
        watch_edit = "<C-w>",
      },
    },
  },
}

function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
  
  -- Setup auto re-add functionality if enabled
  local auto_readd = require("chezmoi.auto_readd")
  auto_readd.setup(M.config)
  
  if M.config.telescope then
    local has_telescope, telescope = pcall(require, "telescope")
    if has_telescope then
      telescope.load_extension("chezmoi")
    end
  end
end

function M.get_config()
  return M.config or default_config
end

return M