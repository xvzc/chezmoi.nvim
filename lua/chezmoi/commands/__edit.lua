local Path = require("plenary.path")
local config = require("chezmoi").config
local notify = require("chezmoi.notify")
local util = require("chezmoi.util")
local base = require("chezmoi.commands.__base")

local edit_cmd = {}

---@return table { watch: boolean }
---@param args string[]
function edit_cmd.__classify_custom_opts(args)
  local ret = {
    watch = config.edit.watch,
    force = config.edit.force,
  }

  local pos = util.__arr_find_first_one_of(args, { "--watch" })
  if pos ~= nil then
    ret.watch = true
    table.remove(args, pos)
  end

  pos = util.__arr_find_first_one_of(args, { "--force" })
  if pos ~= nil then
    ret.force = true
    table.remove(args, pos)
  end

  return ret
end

local function watch(bufnr, source_path, opts)
  -- Use autocmd to make it work as if 'watch' option is given
  local augroup = vim.api.nvim_create_augroup("chezmoi", { clear = false })
  local event = { "BufWritePost" }

  vim.api.nvim_clear_autocmds({
    event = event,
    group = augroup,
    buffer = bufnr,
  })

  vim.api.nvim_create_autocmd(event, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      local args = {
        "--source-path",
        source_path,
      }

      if opts.force then
        table.insert(args, "--force")
      end

      base.execute({
        cmd = "apply",
        args = args,
        on_exit = function(_, code)
          if config.notification.on_apply then
            if code == 0 then
              notify.info("Successfully applied")
            else
              notify.error("Failed to apply")
            end
          end
        end
      })
    end
  })
end

---@ param pos_args string|string[]
---@ param args string[]
function edit_cmd.execute(pos_args, args)
  local opts = edit_cmd.__classify_custom_opts(args or {})

  local resolved_pos_args = util.__resolve_pos_args(pos_args)
  if not resolved_pos_args or #resolved_pos_args ~= 1 then
    notify.panic("Failed to resolve positional arguments. Please specify a target file.")
    return
  end

  local path = Path:new(resolved_pos_args[1])
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

  if opts.watch then
    local bufnr = vim.api.nvim_get_current_buf()
    watch(bufnr, source_path, opts)
  end
end

return edit_cmd
