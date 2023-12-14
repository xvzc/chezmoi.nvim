local notify = require("chezmoi.notify")
local Job = require("plenary.job")
local args = require("chezmoi.args")
local config = require("chezmoi.config").values

local apply_cmd = {}

local args_map = {
  recursive = { "--recursive", args.type.STRING },
  include = { "--include", args.type.LIST },
  exclue = { "--exclude", args.type.LIST },
  init = { "--init", args.type.BOOLEAN }
}

function apply_cmd.execute(targets, opts)
  opts = opts or {}
  local cmd_args = args.parse("apply", targets, args_map, opts)

  local result = Job:new({
    command = "chezmoi",
    args = cmd_args,
    on_stderr = function(_, data)
      notify.error("apply command returned non 0 exit code:\n" .. data)
    end,
    on_exit = function(_, _)
      if config.notification.on_save then
        notify.info("Successfully applied")
      end
    end
  }):sync()

  return result
end

return apply_cmd
