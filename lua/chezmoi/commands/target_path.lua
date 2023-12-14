local Job = require("plenary.job")
local args = require("chezmoi.args")
local notify = require("chezmoi.notify")

local target_path_cmd = {}

function target_path_cmd.execute(targets, opts)
  local result = Job:new({
    command = "chezmoi",
    args = args.parse("target-path", targets, {}, opts),
    on_stderr = function(err, data)
      notify.error("target-path command returned non 0 exit code:\n" .. data)
    end,
  }):sync()

  return result
end

return target_path_cmd
