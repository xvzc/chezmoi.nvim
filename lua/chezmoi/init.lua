local util = require("chezmoi.util")

local chezmoi = {}

local default_config = {
  watch_on_edit = false,
  notification = {
    on_open = true,
    on_apply = true,
  },
}

local function load_config(opts, default)
  opts.watch_on_edit = util.__get_or_default(opts.watch_on_edit, default.watch_on_edit)

  opts.notification = util.__get_or_default(opts.notification, {})
  opts.notification.on_open = util.__get_or_default(
    opts.notification.on_open,
    default.notification.on_open
  )
  opts.notification.on_apply = util.__get_or_default(
    opts.notification.on_apply,
    default.notification.on_apply
  )

  chezmoi.config = opts
end

function chezmoi.setup(opts)
  load_config(opts, default_config)
end

return chezmoi
