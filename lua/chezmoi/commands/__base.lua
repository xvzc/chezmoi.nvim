local notify = require "chezmoi.notify"
local util = require "chezmoi.util"
local Path = require "plenary.path"
local Job = require "plenary.job"

local M = {}

---@class Options
---@field cmd? string
---@field targets? any
---@field args? string[]
---@field on_exit? fun(code: number, signal: number)
---@field on_stderr? fun(error: string, data: string): boolean

---@param opts Options
function M.execute(opts)
  opts = opts or {}
  opts.targets = opts.targets or {}
  opts.args = opts.args or {}

  for i, v in ipairs(opts.targets) do
    local path = Path:new(v)
    opts.targets[i] = path:expand()
  end

  opts.args = util.__normalize_args(opts.args)

  if not opts.cmd then
    notify.panic "command not provided"
    return {}
  end

  local on_stderr_default = function(_, data)
    error("'chezmoi " .. opts.cmd .. "'" .. "command returned non 0 exit code:\n" .. data)
    return nil
  end

  opts.on_stderr = opts.on_stderr or on_stderr_default

  local job = Job:new {
    command = "chezmoi",
    args = vim.tbl_flatten { opts.cmd, opts.targets, opts.args },
    on_stderr = opts.on_stderr,
    on_exit = opts.on_exit,
  }

  job:sync()

  return job:result()
end

return M
