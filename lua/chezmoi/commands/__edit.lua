local Path = require("plenary.path")
local config = require("chezmoi").config
local notify = require("chezmoi.notify")
local util = require("chezmoi.util")
local base = require("chezmoi.commands.__base")

local edit_cmd = {}

---@return table { watch: boolean }
---@param args string[]
function edit_cmd.__classify_custom_opts(args)
  local ret = { watch = false }

  for i, v in ipairs(args) do
    if v == "--watch" then
      ret.watch = true
      table.remove(args, i)
    end
  end

  return ret
end

local function watch(bufnr, source_path)
  -- Use autocmd to make it work as if 'watch' option is given
  local augroup = vim.api.nvim_create_augroup("chezmoi", { clear = false })
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      base.execute({
        cmd = "apply",
        args = {
          "--source-path",
          source_path,
        },
        on_exit = function(_, _)
          if config.notification.on_save then
            notify.info("Successfully applied")
          end
        end
      })
    end
  })
end

---@ param pos_args string|string[]
---@ param __custom_opts string[]
function edit_cmd.execute(pos_args, __custom_opts)
  __custom_opts = edit_cmd.__classify_custom_opts(__custom_opts or {})

  local resolved_pos_args = util.__resolve_pos_args(pos_args)
  if not resolved_pos_args or #resolved_pos_args ~= 1 then
    notify.panic("Failed to resolve positional arguments")
    return
  end

  local path = Path:new(resolved_pos_args[1])

  if not path:exists() then
    local message = "The file " .. tostring(path) .. "does not exists.\n"
    message = message .. "Check the values of the list below\n"
    message = message .. " - 'config.chezmoi.destination_path'\n"
    message = message .. " - 'config.chezmoi.source_path'"
    notify.panic(message)
    return
  end

  local source_path_res = base.execute({
    cmd = "source-path",
    pos_args = { tostring(path) },
  })
  if not source_path_res or #source_path_res ~= 1 then
    notify.panic("Error while querying source file path")
    return
  end

  local source_path = source_path_res[1]

  local ok, _ = pcall(vim.cmd.edit, source_path)
  if ok then
    if config.notification.on_open then
      notify.info("This is a chezmoi managed file")
    end
  else
    notify.error("Failed to open file " .. source_path)
    return
  end

  if __custom_opts.watch or config.watch_on_edit then
    local bufnr = vim.api.nvim_get_current_buf()
    watch(bufnr, source_path)
  end
end

return edit_cmd
