local notify = {}

local function plain(text, level, opts)
  opts = opts or {}
  opts.title = "chezmoi.nvim"
  vim.notify(text, level, opts)
end

function notify.info(text, opts)
  plain(text, vim.log.levels.INFO, opts)
end

function notify.error(text, opts)
  plain(text, vim.log.levels.ERROR, opts)
end

function notify.warn(text, opts)
  plain(text, vim.log.levels.WARN, opts)
end

return notify
