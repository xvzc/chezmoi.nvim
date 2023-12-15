local config = require("chezmoi.config")
local notify = require("chezmoi.notify")

local chezmoi = {}

local default_opts = {
  watch_on_edit = true,
  notification = {
    on_open = true,
    on_save = true,
  },
}

function chezmoi.setup(opts)
  local err = config.init(opts, default_opts)

  if err then
    notify.error(err)
  end
end

return chezmoi
