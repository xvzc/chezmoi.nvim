local config = {}

function config.__get_default(value, default)
  if value == nil then
    return default
  else
    return value
  end
end

function config.init(opts, default_opts)
  opts.watch_on_edit = config.__get_default(opts.watch_on_edit, default_opts.watch_on_edit)

  opts.notification = config.__get_default(opts.notification, {})
  opts.notification.on_open = config.__get_default(opts.notification.on_open, default_opts.notification.on_open)
  opts.notification.on_save = config.__get_default(opts.notification.on_save, default_opts.notification.on_save)

  config.values = opts
end

return config
