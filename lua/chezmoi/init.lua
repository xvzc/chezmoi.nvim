local util = require("chezmoi.util")

local chezmoi = {}

local default_config = {
  watch_on_edit = false,
  notification = {
    on_open = true,
    on_save = true,
  },
}

local function load_config(opts, default)
  opts.watch_on_edit = util.__get_or_default(opts.watch_on_edit, default.watch_on_edit)

  opts.notification = util.__get_or_default(opts.notification, {})
  opts.notification.on_open = util.__get_or_default(
    opts.notification.on_open,
    default.notification.on_open
  )
  opts.notification.on_save = util.__get_or_default(
    opts.notification.on_save,
    default.notification.on_save
  )

  chezmoi.config = opts
end

function chezmoi.setup(opts)
  load_config(opts, default_config)
end

return chezmoi
