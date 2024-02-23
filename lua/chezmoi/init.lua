local chezmoi = {}

local default_config = {
  edit = {
    watch = false,
    force = false,
  },
  notification = {
    on_open = true,
    on_apply = true,
    on_watch = false,
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
