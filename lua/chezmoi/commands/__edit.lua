local Path = require "plenary.path"
local FileType = require "plenary.filetype"
local config = require("chezmoi").config
local notify = require "chezmoi.notify"
local util = require "chezmoi.util"
local apply = require "chezmoi.commands.__apply"
local status = require "chezmoi.commands.__status"
local base = require "chezmoi.commands.__base"
local log = require "chezmoi.log"

FileType.add_table {
  extension = {
    ["age"] = "age",
  },
}

local M = {}

---@param args string[]
---@return table { watch: boolean, force: boolean }
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

  local source_path = vim.api.nvim_buf_get_name(bufnr)
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

  local event = { "BufWritePost" }
  local augroup = vim.api.nvim_create_augroup("chezmoi", { clear = false })
  local autocmds = vim.api.nvim_get_autocmds {
    event = event,
    group = augroup,
    buffer = bufnr,
  }

  local on_watch_conf = config.events.on_watch
  local on_watch_func = function(_)
    if on_watch_conf.notification.enable then
      notify.info(on_watch_conf.notification.msg, on_watch_conf.notification.opts)
    end
  end

  if on_watch_conf.override ~= nil and type(on_watch_conf.override) == "function" then
    on_watch_func = on_watch_conf.override
  end

  if #autocmds == 0 then
    on_watch_func(bufnr)
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
          if apply_exit_code ~= 0 then
            return
          end

          local on_apply_conf = config.events.on_apply
          local on_apply_func = function(_)
            if on_apply_conf.notification.enable then
              notify.info(on_apply_conf.notification.msg, on_apply_conf.notification.opts)
            end
          end

          if
            on_apply_conf.override ~= nil
            and type(on_apply_conf.override) == "function"
          then
            on_apply_func = on_apply_conf.override
          end

          on_apply_func(bufnr)
        end,
      }
    end,
  })
end

---@param opts { targets?: any, args: string[]? }
function M.execute(opts)
  opts = opts or {}
  opts.targets = vim.iter({ opts.targets or {} }):flatten():totable()
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

    local on_open_conf = config.events.on_open
    local on_open_func = function(_)
      if on_open_conf.notification.enable then
        notify.info(on_open_conf.notification.msg, on_open_conf.notification.opts)
      end
    end

    if on_open_conf.override ~= nil and type(on_open_conf.override) == "function" then
      on_open_func = on_open_conf.override
    end

    local file_ext = FileType.detect_from_extension(source_path)

    if file_ext == "age" then
      local rval = 1
      local result = base.execute {
        cmd = "decrypt",
        args = { "--source-path", source_path },
        on_exit = function(_, return_val)
          rval = return_val
        end,
      }

      if rval ~= 0 then
        notify.panic("Failed to decrypt file " .. source_path)
        return
      end

      local decrypted_bufnr = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_lines(decrypted_bufnr, 0, -1, false, result)
      vim.api.nvim_set_current_buf(decrypted_bufnr)

      -- File type detection using target filename
      vim.api.nvim_buf_set_name(decrypted_bufnr, opts.targets[1])
      vim.cmd "filetype detect"

      vim.api.nvim_buf_set_name(decrypted_bufnr, source_path)

      -- Let Chezmoi encrypt and write the file
      vim.api.nvim_set_option_value("modified", false, { buf = decrypted_bufnr })
      vim.api.nvim_set_option_value("buftype", "acwrite", { buf = decrypted_bufnr })
      vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = decrypted_bufnr,
        callback = function()
          if
            vim.api.nvim_get_option_value("modified", { buf = decrypted_bufnr }) ~= true
          then
            return
          end
          base.execute {
            cmd = "encrypt",
            args = { "--output", source_path },
            writer = vim.api.nvim_buf_get_lines(decrypted_bufnr, 0, -1, false),
          }

          vim.api.nvim_set_option_value("modified", false, { buf = decrypted_bufnr })
          vim.api.nvim_exec_autocmds("BufWritePost", { buffer = decrypted_bufnr })
        end,
      })

      on_open_func(decrypted_bufnr)
    else
      local ok, _ = pcall(vim.cmd.edit, source_path)
      if ok then
        on_open_func(bufnr)
      else
        notify.panic("Failed to open file " .. source_path)
        return
      end
    end

    if custom_opts.watch then
      local bufnr = vim.api.nvim_get_current_buf()
      M.watch(bufnr, custom_opts.force)
    end
  end
end

return M
