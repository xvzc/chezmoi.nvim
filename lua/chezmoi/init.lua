local chezmoi = {}

local default_config = {
  extra_args = {},
  edit = {
    watch = false,
    force = false,
    encrypted = false,
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

function chezmoi.setup(opts)
  local config = vim.tbl_deep_extend("force", default_config, opts)
  chezmoi.config = config
  vim.g.chezmoi_setup = 1
end

if vim.g.chezmoi_setup ~= 1 then
  chezmoi.config = default_config
end

return chezmoi
