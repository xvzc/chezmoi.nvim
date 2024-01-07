local notify = {}

local plugin = "chezmoi.nvim"

local function plain(text, level, opts)
  opts = opts or {}
  opts.title = plugin

  if vim.in_fast_event() then
    vim.schedule(function() vim.notify(text, level, opts) end)
  else
    vim.notify(text, level, opts)
  end
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

function notify.panic(text)
  error(plugin .. ": " .. text)
end

return notify
