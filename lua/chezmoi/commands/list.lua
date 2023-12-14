local notify = require("chezmoi.notify")
local Job = require("plenary.job")
local args = require("chezmoi.args")

local list_cmd = {}

local args_map = {
  path_style = { "--path-style", args.type.STRING },
  include = { "--include", args.type.LIST },
  exclue = { "--exclude", args.type.LIST },
}

function list_cmd.execute(opts)
  opts = opts or {}
  local cmd_args = args.parse("list", nil, args_map, opts)

  local job = Job:new({
    command = "chezmoi",
    args = cmd_args,
    on_stderr = function(_, data)
      error("list command returned non 0 exit code:\n" .. data)
    end,
  })

  job:sync()

  return job:result()
end

return list_cmd
