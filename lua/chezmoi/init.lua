local chezmoi = {}

local default_config = {
  edit = {
    watch = false,
    force = false,
  },
  notification = {
    on_open = true,
    on_apply = true,
  },
}

---@private
local function __recursive_apply(key, opts, default)
  if type(opts) == "table" then
    for k, _ in pairs(opts) do
      if default[k] == nil then
        opts[k] = nil
      end
    end
  end

  if type(default[key]) ~= "table" then
    opts[key] = opts[key] or default[key]
    return
  else
    opts[key] = opts[key] or {}
  end

  for k, _ in pairs(default[key]) do
    __recursive_apply(k, opts[key], default[key])
  end
end

local function load_config(opts, default)
  opts = opts or {}
  for k, _ in pairs(default) do
    __recursive_apply(k, opts, default)
  end

  return opts
end

function chezmoi.setup(opts)
  local config = load_config(opts, default_config)
  chezmoi.config = config
  vim.g.chezmoi_setup = 1
end

if vim.g.chezmoi_setup ~= 1 then
  chezmoi.config = default_config
end

return chezmoi
