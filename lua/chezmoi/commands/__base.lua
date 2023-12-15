local notify = require("chezmoi.notify")
local Job = require("plenary.job")
local List = require("plenary.collections.py_list")

local base_cmd = {}

---@param cmd string
---@param pos_args string[]
---@param args string[]
local function __combine_parameters(cmd, pos_args, args)
  return List.concat(
    List.new({ cmd }),
    List.new(pos_args),
    List.new(args)
  )
end

---@alias CMD string
---@alias POS string[]
---@alias ARGS string[]
---@alias ON_STDERR fun(error: string, data: string): boolean
---@alias ON_EXIT fun(code: number, signal: number)
---@param opts { cmd: CMD, pos_args?: POS, args?: ARGS, on_stderr?: ON_STDERR, on_exit?: ON_EXIT }
function base_cmd.execute(opts)
  opts = opts or {}
  opts.pos_args = opts.pos_args or {}
  opts.args = opts.args or {}

  if not opts.cmd then
    notify.panic("command not provided")
    return
  end

  local on_stderr_default = function(_, data)
    error("'chezmoi " .. opts.cmd .. "'" .. "command returned non 0 exit code:\n" .. data)
  end

  opts.on_stderr = opts.on_stderr or on_stderr_default

  local job = Job:new({
    command = "chezmoi",
    args = __combine_parameters(opts.cmd, opts.pos_args, opts.args),
    on_stderr = opts.on_stderr,
    on_exit = opts.on_exit
  })

  job:sync()

  return job:result()
end

return base_cmd
