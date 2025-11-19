local notify = require "chezmoi.notify"
local util = require "chezmoi.util"
local Path = require "plenary.path"
local Job = require "plenary.job"
local config = require("chezmoi").config

local M = {}

---@class Options
---@field cmd? string
---@field targets? any
---@field args? string[]
---@field on_exit? fun(code: number, signal: number)
---@field on_stderr? fun(error: string, data: string)
---@field writer? Job|table|string

---@param opts Options
function M.execute(opts)
  opts = opts or {}
  opts.targets = opts.targets or {}
  opts.args = opts.args or {}
  opts.writer = opts.writer or {}
  for _, v in ipairs(config.extra_args) do
    table.insert(opts.args, v)
  end

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
    error("'chezmoi " .. opts.cmd .. "'" .. "exited with an error:\n" .. data)
  end

  local job = Job:new {
    command = "chezmoi",
    args = vim.iter({ opts.cmd, opts.targets, opts.args }):flatten():totable(),
    on_stderr = opts.on_stderr or on_stderr_default,
    on_exit = opts.on_exit,
    writer = opts.writer,
  }

  job:sync()

  return job:result()
end

return M
