local config = {}

local function get_default(value, default)
  if value == nil then
    return default
  else
    return value
  end
end

function config.init(opts, default_opts)
  opts.config_path = get_default(opts.config_path, default_opts.config_path)
  opts.watch_on_edit = get_default(opts.watch_on_edit, default_opts.watch_on_edit)

  opts.notification = get_default(opts.notification, {})
  opts.notification.on_open = get_default(opts.notification.on_open, default_opts.notification.on_open)
  opts.notification.on_save = get_default(opts.notification.on_save, default_opts.notification.on_save)

  config.values = opts
end

return config
