local Path = require "plenary.path"
local config = require("chezmoi").config
local notify = require "chezmoi.notify"
local util = require "chezmoi.util"
local apply = require "chezmoi.commands.__apply"
local status = require "chezmoi.commands.__status"
local base = require "chezmoi.commands.__base"
local log = require "chezmoi.log"

local M = {}

---@return table { watch: boolean }
---@param args string[]
function M.__parse_custom_opts(args)
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

---@param bufnr number?
---@param force boolean?
function M.watch(bufnr, force)
  -- Use autocmd to make it work as if 'watch' option is given
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  force = force or config.edit.force

  local source_path = vim.fn.bufname(bufnr)
  local event = { "BufWritePost" }

  local status_err = nil
  status.execute {
    args = {
      "--source-path",
      source_path,
    },
    on_stderr = function(_, data)
      status_err = data
    end,
  }

  if status_err then
    log.warn(status_err)
    return
  end

  local augroup = vim.api.nvim_create_augroup("chezmoi", { clear = false })
  local autocmds = vim.api.nvim_get_autocmds {
    event = event,
    group = augroup,
    buffer = bufnr,
  }

  if #autocmds == 0 and config.notification.on_watch then
    notify.info "Edit: This file will be automatically applied"
  end

  vim.api.nvim_clear_autocmds {
    event = event,
    group = augroup,
    buffer = bufnr,
  }

  vim.api.nvim_create_autocmd(event, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      local args = {
        "--source-path",
        source_path,
      }

      if force then
        table.insert(args, "--force")
      end

      apply.execute {
        args = args,
        on_stderr = function(_, data)
          notify.warn(data)
        end,
        on_exit = function(_, apply_exit_code)
          if config.notification.on_apply then
            if apply_exit_code ~= 0 then
              return
            end

            notify.info "Edit: Successfully applied"
          end
        end,
      }
    end,
  })
end

---@param opts { targets?: any, args: string[]? }
function M.execute(opts)
  opts = opts or {}
  opts.targets = vim.tbl_flatten { opts.targets or {} }
  local custom_opts = M.__parse_custom_opts(opts.args or {})

  if vim.tbl_isempty(opts.targets) then
    notify.panic "Failed to resolve positional arguments. Please specify target files."
    return
  end

  for _, target in ipairs(opts.targets) do
    local path = Path:new(target)
    local source_path_res = base.execute {
      cmd = "source-path",
      targets = { tostring(path) },
      on_stderr = function() end,
    }

    if not source_path_res or vim.tbl_isempty(source_path_res) then
      notify.panic("Error while querying source file path for '" .. tostring(path) .. "'")
      return
    end

    local source_path = source_path_res[1]

    local ok, _ = pcall(vim.cmd.edit, source_path)
    if ok then
      if config.notification.on_open then
        notify.info "Edit: Opened a chezmoi-managed file"
      end
    else
      notify.panic("Failed to open file " .. source_path)
      return
    end

    if custom_opts.watch then
      local bufnr = vim.api.nvim_get_current_buf()
      M.watch(bufnr, custom_opts.force)
    end
  end
end

return M
