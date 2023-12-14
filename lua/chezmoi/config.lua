local config = {}

local function get_default(value, default)
  if value == nil then
    return default
  else
    return value
  end
end

function config.init(opts, default_opts)
  opts.watch_on_edit = get_default(opts.watch_on_edit, default_opts.watch_on_edit)

  opts.notification = get_default(opts.notification, {})
  opts.notification.on_open = get_default(
    opts.notification.on_open,
    default_opts.notification.on_open
  )
  opts.notification.on_save = get_default(
    opts.notification.on_save,
    default_opts.notification.on_save
  )

  opts.chezmoi = get_default(opts.chezmoi, {})
  opts.chezmoi.source = get_default(
    opts.chezmoi.source,
    default_opts.chezmoi.source
  )
  opts.chezmoi.config = get_default(
    opts.chezmoi.config,
    default_opts.chezmoi.config
  )
  opts.chezmoi.destination = get_default(
    opts.chezmoi.destination,
    default_opts.chezmoi.destination
  )

  config.values = opts
end

return config
